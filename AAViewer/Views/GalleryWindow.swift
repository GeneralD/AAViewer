//
//  GalleryWindow.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/09.
//

import SwiftUI
import TagKit

struct GalleryWindow: View {
	@EnvironmentObject private var settingModel: AppSettingModel
	@StateObject var galleryModel: GalleryModel

	var body: some View {
		VStack {
			taglist(tags: galleryModel.spellsFilter)
			Spacer(minLength: 0)
			GalleryView(galleryModel: galleryModel)
				.environmentObject(settingModel)
				.searchable(text: $galleryModel.textFilter, placement: .toolbar)
				.toolbar { toolbar }
			Spacer(minLength: 0)
		}
	}
}

private extension GalleryWindow {
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
