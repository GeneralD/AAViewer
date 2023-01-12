//
//  GalleryView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/09.
//

import SFSafeSymbols
import SwiftUI
import TagKit

struct GalleryView: View {
	@EnvironmentObject private var settingModel: AppSettingModel
	@StateObject private var galleryModel = GalleryModel()

	var body: some View {
		VStack {
			TagListView(tags: galleryModel.spellsFilter)
				.onOnTap { tag in galleryModel.spellsFilter.remove(tag) }
			Spacer(minLength: 0)
			GalleryTableView()
				.environmentObject(settingModel)
				.environmentObject(galleryModel)
				.searchable(text: $galleryModel.textFilter, placement: .toolbar)
				.toolbar { toolbar }
			Spacer(minLength: 0)
		}
		.focusedSceneObject(galleryModel)
	}
}

private extension GalleryView {
	@ViewBuilder
	var toolbar: some View {
		if !galleryModel.spellsFilter.isEmpty {
			Button {
				galleryModel.spellsFilter.removeAll()
			} label: {
				Image(systemSymbol: .tagSlash)
			}
			Button {
				let pasteboard = NSPasteboard.general
				pasteboard.clearContents()
				pasteboard.setString(galleryModel.spellsFilter.joined(separator: ", "), forType: .string)
			} label: {
				Image(systemSymbol: .clipboard)
			}
			Spacer()
		}

		Button {
			galleryModel.openDirectoryPicker()
		} label: {
			Image(systemSymbol: .folder)
		}
		if let location = galleryModel.folderURL {
			Button(location.lastPathComponent) {
				NSWorkspace.shared.open(location)
			}
		}
		if !galleryModel.items.isEmpty {
			Text(R.string.localizable.labelNumberOfItems(galleryModel.items.count))
		}
		Spacer()

		Button {
			settingModel.decreaseGalleryColumn()
		} label: {
			Image(systemSymbol: .plusMagnifyingglass)
		}
		Button {
			settingModel.increaseGalleryColumn()
		} label: {
			Image(systemSymbol: .minusMagnifyingglass)
		}
		switch settingModel.galleryScrollAxis {
		case .vertical:
			Button {
				settingModel.galleryScrollAxis = .horizontal
			} label: {
				Image(systemSymbol: .alignHorizontalLeft)
			}
		case .horizontal:
			Button {
				settingModel.galleryScrollAxis = .vertical
			} label: {
				Image(systemSymbol: .alignVerticalTop)
			}
		default:
			Divider()
		}
		Spacer()
		switch galleryModel.mode {
		case .viewer:
			Button {
				galleryModel.mode = .multipleSelection(selected: [], hideSelected: false)
			} label: {
				Image(systemSymbol: .checkmark)
			}
		case let .multipleSelection(selected, hideSelected):
			Button {
				galleryModel.mode = .viewer
			} label: {
				Image(systemSymbol: .eye)
			}
			if !selected.isSuperset(of: galleryModel.items) {
				Button {
					galleryModel.mode = .multipleSelection(selected: selected.union(galleryModel.items), hideSelected: hideSelected)
				} label: {
					Image(systemSymbol: .checkmarkCircleFill)
						.foregroundColor(.blue)
				}
			}
			if !hideSelected, !selected.isDisjoint(with: galleryModel.items) {
				Button {
					galleryModel.mode = .multipleSelection(selected: selected.subtracting(galleryModel.items), hideSelected: hideSelected)
				} label: {
					Image(systemSymbol: .checkmarkCircle)
						.foregroundColor(.blue)
				}
			}
			Button {
				galleryModel.mode = .multipleSelection(selected: selected, hideSelected: !hideSelected)
			} label: {
				Image(systemSymbol: hideSelected ? .appBadgeCheckmark : .squareDotted)
			}
			if !selected.isEmpty {
				Button {
					// TODO: confirm in alert
					galleryModel.deleteSelectedItems()
				} label: {
					Image(systemSymbol: .trash)
						.foregroundColor(.red)
				}
				Text(R.string.localizable.labelNumberOfSelectedItems(selected.count))
			}
		}
	}
}
