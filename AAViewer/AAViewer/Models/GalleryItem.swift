//
//  GalleryItem.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import Foundation

struct GalleryItem {
	let url: URL
	let spells: [Spell]
}

extension GalleryItem: Identifiable {
	var id: URL { url }
}
