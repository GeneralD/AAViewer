//
//  AAViewerApp.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import SwiftUI
import TagKit

@main
struct AAViewerApp: App {
	@StateObject private var galleryModel = GalleryModel()
	@StateObject private var settingModel = SettingModel()

	var body: some Scene {
		WindowGroup {
			VStack {
				taglist(tags: galleryModel.spellsFilter)
				Spacer(minLength: 0)
				GalleryView(galleryModel: galleryModel, settingModel: settingModel)
					.searchable(text: $galleryModel.textFilter, placement: .toolbar)
					.toolbar { toolbar }
				Spacer(minLength: 0)
			}
		}
		.windowStyle(.hiddenTitleBar)
		.commands { commands }
	}
}

private extension AAViewerApp {
	@ViewBuilder
	var toolbar: some View {
		if !galleryModel.spellsFilter.isEmpty {
			Button {
				galleryModel.spellsFilter.removeAll()
			} label: {
				Image(systemName: "tag.slash")
			}
			Button {
				let pasteboard = NSPasteboard.general
				pasteboard.clearContents()
				pasteboard.setString(galleryModel.spellsFilter.joined(separator: ", "), forType: .string)
			} label: {
				Image(systemName: "clipboard")
			}
			Spacer()
		}

		Button {
			galleryModel.openDirectoryPicker()
		} label: {
			Image(systemName: "folder")
		}
		if let location = galleryModel.folderURL {
			Button(location.lastPathComponent) {
				NSWorkspace.shared.open(location)
			}
		}
		Spacer()

		Button {
			settingModel.decreaseGalleryColumn()
		} label: {
			Image(systemName: "plus.magnifyingglass")
		}
		Button {
			settingModel.increaseGalleryColumn()
		} label: {
			Image(systemName: "minus.magnifyingglass")
		}
		switch settingModel.galleryScrollAxis {
		case .vertical:
			Button {
				settingModel.galleryScrollAxis = .horizontal
			} label: {
				Image(systemName: "align.vertical.top")
			}
		case .horizontal:
			Button {
				settingModel.galleryScrollAxis = .vertical
			} label: {
				Image(systemName: "align.horizontal.left")
			}
		default:
			Divider()
		}
		Spacer()
	}

	@CommandsBuilder
	var commands: some Commands {
		CommandGroup(after: .newItem) {
			Divider()
			Button("Open...") {
				galleryModel.openDirectoryPicker()
			}
			.keyboardShortcut("o", modifiers: .command)
		}
		CommandGroup(after: .sidebar) {
			Menu("Scroll Direction") {
				Button("Horizontal") {
					settingModel.galleryScrollAxis = .horizontal
				}
				.keyboardShortcut("h", modifiers: [.command, .option])
				.disabled(settingModel.galleryScrollAxis == .horizontal)
				Button("Vertical") {
					settingModel.galleryScrollAxis = .vertical
				}
				.keyboardShortcut("v", modifiers: [.command, .option])
				.disabled(settingModel.galleryScrollAxis == .vertical)
			}
			Menu("Zoom (Columns: \(settingModel.galleryColumns))") {
				Button("Zoom In") {
					settingModel.decreaseGalleryColumn()
				}
				.keyboardShortcut("+", modifiers: .command)
				Button("Zoom Out") {
					settingModel.increaseGalleryColumn()
				}
				.keyboardShortcut("-", modifiers: .command)
				Button("Reset") {
					settingModel.resetGalleryColumn()
				}
				.keyboardShortcut("0", modifiers: .command)
			}
		}
		CommandGroup(after: .pasteboard) {
			Divider()
			Button("Find") {
				NSApplication.searchToolbar?.beginSearchInteraction()
			}
			.keyboardShortcut("f", modifiers: .command)
		}
	}

	@ViewBuilder
	func taglist(tags: some Sequence<String>) -> some View {
		TagList(tags: .init(tags)) { tag in
			Text(tag)
				.padding(.all, 4)
				.background(Color(seed: tag))
				.foregroundColor(.white)
				.cornerRadius(32)
				.onTapGesture { galleryModel.spellsFilter.remove(tag) }
		}
	}
}
