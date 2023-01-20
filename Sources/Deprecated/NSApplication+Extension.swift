//
//  NSApplication+Extension.swift
//
//  Created by Yumenosuke Koukata on 2023/01/09.
//

import AppKit

extension NSApplication {
	static var searchToolbar: NSSearchToolbarItem? {
		guard let toolbarItems = shared.keyWindow?.toolbar?.items,
		      let item = toolbarItems.first(where: { $0.itemIdentifier.rawValue == "com.apple.SwiftUI.search" }),
		      let search = item as? NSSearchToolbarItem else { return nil }
		return search
	}
}
