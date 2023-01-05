//
//  ContentView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//z

import Combine
import Kingfisher
import SwiftUI
import WaterfallGrid

struct GalleryView: View {
	
	@ObservedObject var galleryModel = GalleryModel()
	@ObservedObject var settingModel = SettingModel()
	
	var body: some View {
		if galleryModel.items.isEmpty {
			Button("Open Folder") {
				galleryModel.openDirectoryPicker()
			}.buttonStyle(.borderless)
		}
		else {
			ScrollView(settingModel.galleryScrollAxis) {
				WaterfallGrid(galleryModel.items) { item in
					VStack {
						KFImage(item.url)
							.resizable()
							.aspectRatio(contentMode: .fit)
						if settingModel.showPrompt, !item.spells.isEmpty {
							SpellsView(spells: item.spells)
						}
					}
					.cornerRadius(8)
				}
				.scrollOptions(direction: settingModel.galleryScrollAxis)
				.gridStyle(columns: settingModel.galleryColumns)
				.padding(8)
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		GalleryView()
	}
}
