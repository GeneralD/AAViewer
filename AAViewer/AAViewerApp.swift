//
//  AAViewerApp.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import SwiftUI

@main
struct AAViewerApp: App {
	@StateObject var galleryModel = GalleryModel()
	@StateObject var settingModel = SettingModel()

	var body: some Scene {
		WindowGroup {
			VStack {
				SpellsView(spells: galleryModel.spellsFilter)
				GalleryView(galleryModel: galleryModel, settingModel: settingModel)
					.searchable(text: $galleryModel.textFilter)
			}
		}
		.windowStyle(.hiddenTitleBar)
		.commands {
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
					}.keyboardShortcut("+", modifiers: .command)
					Button("Zoom Out") {
						settingModel.increaseGalleryColumn()
					}.keyboardShortcut("-", modifiers: .command)
					Button("Reset") {
						settingModel.resetGalleryColumn()
					}.keyboardShortcut("0", modifiers: .command)
				}
			}
		}
	}
}
