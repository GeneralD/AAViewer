//
//  GalleryTableView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import Kingfisher
import SwiftUI
import WaterfallGrid

struct GalleryTableView: View {
	@EnvironmentObject private var settingModel: AppSettingModel
	@StateObject var galleryModel = GalleryModel()

	@State private var selectedID: GalleryItem.ID?

	var body: some View {
		if galleryModel.filteredItems.isEmpty {
			Button {
				galleryModel.openDirectoryPicker()
			} label: {
				HStack {
					Image(systemName: "folder.fill")
					Text("Open Folder")
				}
				.padding(.all, 16)
			}
		}
		else {
			ScrollView(settingModel.galleryScrollAxis) {
				WaterfallGrid(galleryModel.filteredItems) { item in
					KFImage(item.url)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.cornerRadius(8)
						.onTapGesture { selectedID = item.id }
						.popover(isPresented: isPresented(itemID: item.id)) {
							TagListView(tags: item.spells.map(\.phrase).reduce(into: []) { accum, phrase in
								guard !galleryModel.spellsFilter.contains(phrase) else { return }
								accum.append(phrase)
							})
							.onOnTap { tag in
								galleryModel.spellsFilter.insert(tag)
							}
						}
				}
				.scrollOptions(direction: settingModel.galleryScrollAxis)
				.gridStyle(columns: settingModel.galleryColumns)
				.padding(8)
			}
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
