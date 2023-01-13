//
//  GalleryModel.swift
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import AppKit
import Combine
import CoreImage
import Foundation

class GalleryModel: ObservableObject {

	@Published var textFilter: String = ""
	@Published var spellsFilter: Set<String> = .init()
	@Published var mode: Mode = .viewer

	@Published private(set) var folderURL: URL?
	@Published private(set) var items: [GalleryItem] = [] // items to display
	@Published private(set) var isEmpty = true

	@Published private var allItems: [GalleryItem] = []

	enum Mode {
		case viewer
		case multipleSelection(selected: Set<GalleryItem>, hideSelected: Bool)
	}

	init() {
		$folderURL
			.compactMap { $0 }
			.compactMap(compatibleFileURLs(parentDirectory:))
			.map { urls in
				urls.chunked(by: 50) // load 50 at a time
					.publisher
					.delay(for: 1, scheduler: DispatchQueue.global())
					.manyMap(item(from:))
					.scan([GalleryItem](), +)
			}
			.switchToLatest()
			.assign(to: &$allItems)

		$folderURL
			.map { _ in .viewer }
			.assign(to: &$mode)

		$allItems
			.map(\.isEmpty)
			.assign(to: &$isEmpty)
		
		$allItems
			.combineLatest($textFilter, $spellsFilter, filtered(items:searchText:spells:))
			.combineLatest($mode, displayed(items:by:))
			.subscribe(on: DispatchQueue.global())
			.receive(on: DispatchQueue.main)
			.assign(to: &$items)
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

	func deleteActual(item: GalleryItem) {
		try? FileManager.default.removeItem(at: item.url)
		guard let index = allItems.firstIndex(of: item) else { return }
		allItems.remove(at: index)
		guard case let .multipleSelection(selected, hideSelected) = mode else { return }
		mode = .multipleSelection(selected: selected.subtracting([item]), hideSelected: hideSelected)
	}

	func deleteSelectedItems() {
		guard case let .multipleSelection(selected, _) = mode else { return }
		deleteActual(items: selected)
	}
}

private extension GalleryModel {
	func resetFilters() {
		textFilter = ""
		spellsFilter = []
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

	func displayed(items: [GalleryItem], by mode: Mode) -> [GalleryItem] {
		switch mode {
		case .viewer, .multipleSelection(_, hideSelected: false):
			return items
		case let .multipleSelection(selected, true):
			return items.filter { item in
				!selected.contains(item)
			}
		}
	}

	func deleteActual(items: some Sequence<GalleryItem>) {
		let deletedItems = items.compactMap { item in
			(try? FileManager.default.removeItem(at: item.url)).flatMap { item }
		}
		allItems = allItems.filter { item in
			!deletedItems.contains(item)
		}
		guard case let .multipleSelection(selected, hideSelected) = mode else { return }
		mode = .multipleSelection(selected: selected.subtracting(deletedItems), hideSelected: hideSelected)
	}
}

private func compatibleFileURLs(parentDirectory url: URL) -> [URL]? {
	guard let fileUrls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else { return nil }
	let extensions = ["jpg", "jpeg", "png", "gif"]
	return fileUrls.filter { url in
		extensions.contains(url.pathExtension.lowercased())
	}
}

private func item(from url: URL) -> GalleryItem {
	let prompt = prompt(from: url)
	return GalleryItem(url: url, spells: prompt.flatMap(spells(from:)) ?? [], originalPrompt: prompt ?? "")
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
