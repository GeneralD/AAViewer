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

	@State private var hoveringID: GalleryItem.ID?
	
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
						.overlay {
							if item.id == hoveringID {
								TagList(tags: item.spells.map(\.phrase)) { tag in
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
						.cornerRadius(8)
						.onHover { hovering in
							guard hovering else {
								hoveringID = nil
								return
							}
							hoveringID = item.id
						}
				}
				.scrollOptions(direction: settingModel.galleryScrollAxis)
				.gridStyle(columns: settingModel.galleryColumns)
				.padding(8)
			}
		}
	}
}

struct GalleryView_Previews: PreviewProvider {
	static var previews: some View {
		GalleryView()
	}
}
