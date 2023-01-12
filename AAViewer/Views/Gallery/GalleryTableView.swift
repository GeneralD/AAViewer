//
//  GalleryTableView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import Kingfisher
import SFSafeSymbols
import SwiftUI
import WaterfallGrid
import QuickLook

struct GalleryTableView: View {
	@EnvironmentObject private var settingModel: AppSettingModel
	@EnvironmentObject private var galleryModel: GalleryModel

	@State private var selectedID: GalleryItem.ID?
	@State private var alertDeleteFile = false
	@State private var previewURL: URL?

	var body: some View {
		if galleryModel.isEmpty {
			Button {
				galleryModel.openDirectoryPicker()
			} label: {
				HStack {
					Image(systemSymbol: .folderFill)
					Text(R.string.localizable.buttonOpenFolder)

				}
				.padding(.all, 16)
			}
		}
		else {
			ScrollView(settingModel.galleryScrollAxis) {
				WaterfallGrid(galleryModel.items) { item in
					KFImage(item.url)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.cornerRadius(8)
						.onTapGesture {
							selectedID = item.id
							if case let .multipleSelection(selected, hideSelected) = galleryModel.mode {
								if selected.contains(item) {
									galleryModel.mode = .multipleSelection(selected: selected.subtracting([item]), hideSelected: hideSelected)
								} else {
									galleryModel.mode = .multipleSelection(selected: selected.union([item]), hideSelected: hideSelected)
								}
							}
						}
						.popover(isPresented: isPresented(itemID: item.id)) {
							GalleryItemControlView(item: item, excludeTags: galleryModel.spellsFilter)
								.onAction(perform: { action in
									switch action {
									case .copyPrompt:
										let pasteboard = NSPasteboard.general
										pasteboard.clearContents()
										pasteboard.setString(item.originalPrompt, forType: .string)
									case .previewFile:
										previewURL = item.url
									case .openFile:
										NSWorkspace.shared.open(item.url)
									case .deleteFile:
										galleryModel.deleteActual(item: item)
									case .select(let tag):
										galleryModel.spellsFilter.insert(tag)
									}
								})
								.frame(minWidth: 320)
								.padding(.all, 16)
						}
						.overlay(alignment: .topLeading) {
							if case let .multipleSelection(selected, _) = galleryModel.mode {
								Image(systemSymbol: selected.contains(item) ? .checkmarkCircleFill : .checkmarkCircle)
									.font(.system(size: 18))
									.foregroundColor(.blue)
									.padding(4)
							}
						}
				}
				.scrollOptions(direction: settingModel.galleryScrollAxis)
				.gridStyle(columns: settingModel.galleryColumns)
				.padding(8)
			}
			.padding(.top, 0.1) // Ensure toolbars and content do not overlap
			.quickLookPreview($previewURL)
		}
	}
}

private extension GalleryTableView {

	func isPresented(itemID: GalleryItem.ID) -> Binding<Bool> {
		.init(get: {
			selectedID == itemID
		}, set: { value in
			selectedID = value ? itemID : nil
		})
	}
}

struct GalleryView_Previews: PreviewProvider {
	static var previews: some View {
		GalleryTableView()
	}
}
