//
//  GalleryItemControlView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/10.
//

import SFSafeSymbols
import SwiftUI

struct GalleryItemControlView: View {
	private let item: GalleryItem
	private let excludeTags: any Sequence<String>
	private var action: ((GalleryItemAction) -> Void)? = nil

	@State private var alertDeleteFile = false

	init(item: GalleryItem, excludeTags: any Sequence<String>) {
		self.item = item
		self.excludeTags = excludeTags
	}

	var body: some View {
		VStack(alignment: .center, spacing: 8) {
			Text(item.url.lastPathComponent)
			Divider()
			TagListView(tags: item.spells.map(\.phrase).reduce(into: []) { accum, phrase in
				guard !excludeTags.contains(phrase) else { return }
				accum.append(phrase)
			})
			.onOnTap { tag in
				action?(.select(tag: tag))
			}
			Divider()
			HStack {
				Button {
					action?(.copyPrompt)
				} label: {
					Image(systemSymbol: .clipboard)
					Text(R.string.localizable.buttonCopyPrompt)
				}
				Button {
					action?(.previewFile)
				} label: {
					Image(systemSymbol: .eye)
					Text(R.string.localizable.buttonPreview)
				}
				Button {
					action?(.openFile)
				} label: {
					Image(systemSymbol: .photo)
					Text(R.string.localizable.buttonOpenImage)
				}
				Button {
					alertDeleteFile = true
				} label: {
					Image(systemSymbol: .trash)
					Text(R.string.localizable.buttonDeleteImage)
				}
				.alert(isPresented: $alertDeleteFile) {
					alert(deleteItem: item)
				}
			}
		}
	}

	@inlinable func onAction(perform action: @escaping (GalleryItemAction) -> Void) -> Self {
		var copied = self
		copied.action = action
		return copied
	}

	enum GalleryItemAction {
		case copyPrompt, previewFile, openFile, deleteFile, select(tag: String)
	}
}

private extension GalleryItemControlView {
	func alert(deleteItem: GalleryItem) -> Alert {
		let path = item.url.absoluteString
		return Alert(title: Text(R.string.localizable.alertTitleConfirmDeletion),
					 message: Text(path.removingPercentEncoding ?? path),
					 primaryButton: .destructive(Text(R.string.localizable.alertButtonCommonYes), action: { action?(.deleteFile) }),
					 secondaryButton: .cancel())
	}
}
