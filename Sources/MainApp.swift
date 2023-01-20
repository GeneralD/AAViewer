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
			Button(R.string.localizable.menuButtonOpen()) {
				focused?.openDirectoryPicker()
			}
					.keyboardShortcut("o", modifiers: .command)
		}
		CommandGroup(after: .sidebar) {
			Menu(R.string.localizable.menuLabelScrollDirection()) {
				Button(R.string.localizable.menuLabelScrollDirectionHorizontal()) {
					settingModel.galleryScrollAxis = .horizontal
				}
						.keyboardShortcut("h", modifiers: [.command, .option])
						.disabled(settingModel.galleryScrollAxis == .horizontal)
				Button(R.string.localizable.menuButtonScrollDirectionVertical()) {
					settingModel.galleryScrollAxis = .vertical
				}
						.keyboardShortcut("v", modifiers: [.command, .option])
						.disabled(settingModel.galleryScrollAxis == .vertical)
			}
			Menu(R.string.localizable.menuLabelZoom(settingModel.galleryColumns)) {
				Button(R.string.localizable.menuButtonZoomIn()) {
					settingModel.decreaseGalleryColumn()
				}
						.keyboardShortcut("+", modifiers: .command)
				Button(R.string.localizable.menuButtonZoomOut()) {
					settingModel.increaseGalleryColumn()
				}
						.keyboardShortcut("-", modifiers: .command)
				Button(R.string.localizable.menuButtonZoomReset()) {
					settingModel.resetGalleryColumn()
				}
						.keyboardShortcut("0", modifiers: .command)
			}
		}
		CommandGroup(after: .pasteboard) {
			Divider()
			Button(R.string.localizable.menuButtonFind()) {
				NSApplication.searchToolbar?.beginSearchInteraction()
			}
					.keyboardShortcut("f", modifiers: .command)
		}
	}
}
