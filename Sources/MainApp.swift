//
//  MainApp.swift
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import SwiftUI

@main
struct MainApp: App {
	@FocusedObject private var focused: GalleryModel?
	@StateObject private var settingModel = AppSettingModel()

	var body: some Scene {
		WindowGroup {
			GalleryView()
				.environmentObject(settingModel)
		}
		.windowStyle(.hiddenTitleBar)
		.commands { commands }
	}
}

private extension MainApp {
	@CommandsBuilder
	var commands: some Commands {
		CommandGroup(after: .newItem) {
			Divider()
			Button("Open...") {
				focused?.openDirectoryPicker()
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
}
