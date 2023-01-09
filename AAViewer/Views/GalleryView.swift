//
//  ContentView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import Kingfisher
import SwiftUI
import TagKit
import WaterfallGrid

struct GalleryView: View {
	@ObservedObject var galleryModel = GalleryModel()
	@ObservedObject var settingModel = SettingModel()

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
							taglist(tags: item.spells.map(\.phrase).reduce(into: []) { accum, phrase in
								guard !galleryModel.spellsFilter.contains(phrase) else { return }
								accum.append(phrase)
							})
						}
				}
				.scrollOptions(direction: settingModel.galleryScrollAxis)
				.gridStyle(columns: settingModel.galleryColumns)
				.padding(8)
			}
		}
	}
}

private extension GalleryView {

	func isPresented(itemID: GalleryItem.ID) -> Binding<Bool> {
		.init(get: {
			selectedID == itemID
		}, set: { value in
			selectedID = value ? itemID : nil
		})
	}

	@ViewBuilder
	func taglist(tags: some Sequence<String>) -> some View {
		TagList(tags: .init(tags)) { tag in
			Text(tag)
				.padding(.all, 4)
				.background(Color(seed: tag))
				.foregroundColor(.white)
				.cornerRadius(32)
				.onTapGesture {
					galleryModel.spellsFilter.insert(tag)
				}
		}
	}
}

struct GalleryView_Previews: PreviewProvider {
	static var previews: some View {
		GalleryView()
	}
}
