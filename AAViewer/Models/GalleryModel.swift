//
//  GalleryModel.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import AppKit
import Combine
import CoreImage
import Foundation

class GalleryModel: ObservableObject {
	@Published private(set) var folderURL: URL?
	@Published private(set) var items: [GalleryItem] = []

	private var cancellables = Set<AnyCancellable>()

	init() {
		configureBindings()
	}
}

extension GalleryModel {
	func openDirectoryPicker() {
		let open = NSOpenPanel()
		open.canChooseFiles = false
		open.canChooseDirectories = true
		guard open.runModal() == .OK else { return }
		folderURL = open.url
	}
}

private extension GalleryModel {
	func configureBindings() {
		let manager = FileManager.default
		let imageExtensions = ["jpg", "jpeg", "png", "gif"]

		$folderURL
			.compactMap { $0 }
			.tryMap { url in try manager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) }
			.map { urls in urls
					.filter { url in imageExtensions.contains(url.pathExtension.lowercased()) }
					.map { url in GalleryItem(url: url, spells: prompt(from: url).flatMap(spells(from:)) ?? []) }
			}
			.receive(on: DispatchQueue.main)
			.sink { _ in } receiveValue: { [weak self] items in
				self?.items = items
			}
			.store(in: &cancellables)
	}
}

private func prompt(from url: URL) -> String? {
	guard let image = CIImage(contentsOf: url),
		  let pngProps = image.properties[kCGImagePropertyPNGDictionary as String] as? [String : Any],
		  let description = pngProps[kCGImagePropertyPNGDescription as String] as? String else { return nil }
	return description
}

private func spells(from prompt: String) -> [Spell] {
	prompt
		.split(separator: ",")
		.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
		.filter { !$0.isEmpty }
		.map(Spell.from)
		.reduce(into: []) { accum, spell in
			if let index = accum.map(\.phrase).firstIndex(of: spell.phrase), accum[index].enhanced < spell.enhanced {
				accum.remove(at: index)
			}
			accum.append(spell)
		}
}
