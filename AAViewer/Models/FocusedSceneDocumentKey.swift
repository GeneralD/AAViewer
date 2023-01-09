//
//  FocusedSceneDocumentKey.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/10.
//

import SwiftUI

struct FocusedSceneDocumentKey: FocusedValueKey {
	typealias Value = GalleryModel
}

extension FocusedValues {
	var focusedSceneDocument: FocusedSceneDocumentKey.Value? {
		get { self[FocusedSceneDocumentKey.self] }
		set { self[FocusedSceneDocumentKey.self] = newValue }
	}
}
