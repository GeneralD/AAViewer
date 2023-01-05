//
//  SettingModel.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import Combine
import Foundation
import SwiftUI
import SwiftyUserDefaults

class SettingModel: ObservableObject {
	@Published var galleryScrollAxis: Axis.Set = Defaults.galleryScrollAxis {
		didSet(value) {
			Defaults.galleryScrollAxis = value
		}
	}
	@Published private(set) var galleryColumns = Defaults.galleryColumns {
		didSet(value) {
			Defaults.galleryColumns = value
		}
	}
	@Published var showPrompt = Defaults.showPrompt {
		didSet(value) {
			Defaults.showPrompt = value
		}
	}

	func increaseGalleryColumn() {
		guard galleryColumns < 20 else { return }
		galleryColumns += 1
	}

	func decreaseGalleryColumn() {
		guard galleryColumns > 1 else { return }
		galleryColumns -= 1
	}

	func resetGalleryColumn() {
		galleryColumns = 2
	}
}

private extension DefaultsKeys {
	var galleryScrollAxis: DefaultsKey<Axis.Set> { .init("galleryScrollAxis", defaultValue: .horizontal) }
	var galleryColumns: DefaultsKey<Int> { .init("galleryColumns", defaultValue: 2) }
	var showPrompt: DefaultsKey<Bool> { .init("showPrompt", defaultValue: true) }
}

extension Axis.Set: DefaultsSerializable {}
