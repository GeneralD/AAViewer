//
//  GalleryItemControlView.swift
//
//  Created by Yumenosuke Koukata on 2023/01/10.
//

import SFSafeSymbols
import SwiftUI

struct GalleryItemControlView: View {
	@Environment(\.galleryItemControlAction) private var action
	
	private let item: GalleryItem
	private let excludeTags: any Sequence<String>
	
	@State private var alertDeleteFile = false
	
	init(item: GalleryItem, excludeTags: any Sequence<String>) {
		self.item = item
		self.excludeTags = excludeTags
	}
	
	var body: some View {
		VStack(alignment: .center, spacing: 8) {
			Text(item.url.lastPathComponent)
			Divider()
			TagListView(tags: tags)
				.itemSelected { tag in
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
	
	enum Action {
		case copyPrompt, previewFile, openFile, deleteFile, select(tag: String)
	}
}

private extension GalleryItemControlView {
	func alert(deleteItem: GalleryItem) -> Alert {
		let path = item.url.absoluteString
		return Alert(title: Text(R.string.localizable.alertTitleConfirmDeletion),
					 message: Text(path.removingPercentEncoding ?? path),
					 primaryButton: .destructive(Text(R.string.localizable.alertButtonCommonYes)) { action?(.deleteFile) },
					 secondaryButton: .cancel())
	}
	
	var tags: [String] {
		item.spells.map(\.phrase).reduce(into: []) { accum, phrase in
			guard !excludeTags.contains(phrase) else { return }
			accum.append(phrase)
		}
	}
}

extension View {
	func galleryItemControlAction(_ value: @escaping (GalleryItemControlView.Action) -> Void) -> some View {
		environment(\.galleryItemControlAction, value)
	}
}

private struct GalleryItemActionKey: EnvironmentKey {
	static var defaultValue: ((GalleryItemControlView.Action) -> Void)? = nil
}

private extension EnvironmentValues {
	var galleryItemControlAction: ((GalleryItemControlView.Action) -> Void)? {
		get { self[GalleryItemActionKey.self] }
		set { self[GalleryItemActionKey.self] = newValue }
	}
}
