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
	@Published private(set) var filteredItems: [GalleryItem] = []
	
	@Published var textFilter: String = ""
	@Published var spellsFilter: Set<String> = .init()
	
	init() {
		$folderURL
			.compactMap { $0 }
			.compactMap(loadGalleryItems(from:))
			.combineLatest($textFilter, $spellsFilter, filtered(items: searchText: spells:))
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.assign(to: &$filteredItems)
	}
}

extension GalleryModel {
	func openDirectoryPicker() {
		let open = NSOpenPanel()
		open.canChooseFiles = false
		open.canChooseDirectories = true
		guard open.runModal() == .OK else { return }
		resetFilters()
		folderURL = open.url
	}
}

private extension GalleryModel {
	func resetFilters() {
		textFilter = ""
		spellsFilter = []
	}

	func loadGalleryItems(from url: URL) -> [GalleryItem]? {
		let manager = FileManager.default
		let imageExtensions = ["jpg", "jpeg", "png", "gif"]
		guard let fileUrls = try? manager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else { return nil }
		return fileUrls
			.filter { url in imageExtensions.contains(url.pathExtension.lowercased()) }
			.map { url in
				let prompt = prompt(from: url)
				return GalleryItem(url: url, spells: prompt.flatMap(spells(from:)) ?? [], originalPrompt: prompt ?? "")
			}
	}

	func prompt(from url: URL) -> String? {
		guard let image = CIImage(contentsOf: url),
			  let pngProps = image.properties[kCGImagePropertyPNGDictionary as String] as? [String : Any],
			  let description = pngProps[kCGImagePropertyPNGDescription as String] as? String else { return nil }
		return description
	}

	func spells(from prompt: String) -> [Spell] {
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

	func filtered(items: [GalleryItem], searchText: String, spells: Set<String>) -> [GalleryItem] {
		return items.filter { item in
			guard spells.isSubset(of: item.spells.map(\.phrase)) else { return false }
			guard !searchText.isEmpty else { return true }
			let text = searchText.lowercased()
			guard item.url.lastPathComponent.lowercased().contains(text)
					|| item.originalPrompt.lowercased().contains(text) else { return false }
			return true
		}
	}
}
