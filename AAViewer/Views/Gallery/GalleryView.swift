//
//  GalleryView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/09.
//

import SwiftUI
import TagKit

struct GalleryView: View {
	@EnvironmentObject private var settingModel: AppSettingModel
	@StateObject private var galleryModel = GalleryModel()

	var body: some View {
		VStack {
			TagListView(tags: galleryModel.spellsFilter)
				.onOnTap { tag in galleryModel.spellsFilter.remove(tag) }
			Spacer(minLength: 0)
			GalleryTableView()
				.environmentObject(settingModel)
				.environmentObject(galleryModel)
				.searchable(text: $galleryModel.textFilter, placement: .toolbar)
				.toolbar { toolbar }
			Spacer(minLength: 0)
		}
		.focusedSceneObject(galleryModel)
	}
}

private extension GalleryView {
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
}
