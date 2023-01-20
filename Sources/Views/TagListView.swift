//
//  TagListView.swift
//
//  Created by Yumenosuke Koukata on 2023/01/10.
//

import SwiftUI
import TagKit

struct TagListView: View {
	@Environment(\.itemSelected) private var itemSelectedAction

	private let tags: [String]

	init(tags: some Sequence<String>) {
		self.tags = .init(tags)
	}

	var body: some View {
		TagList(tags: .init(tags)) { tag in
			Text(tag)
					.padding(.all, 4)
					.background(Color(seed: tag))
					.foregroundColor(.white)
					.cornerRadius(32)
					.onTapGesture { itemSelectedAction?(tag) }
		}
	}
}

extension View {
	func itemSelected(_ value: @escaping (String) -> Void) -> some View {
		environment(\.itemSelected, value)
	}
}

private struct ItemSelected: EnvironmentKey {
	static var defaultValue: ((String) -> Void)? = nil
}

private extension EnvironmentValues {
	var itemSelected: ((String) -> Void)? {
		get { self[ItemSelected.self] }
		set { self[ItemSelected.self] = newValue }
	}
}

struct TagListView_Previews: PreviewProvider {
	static var previews: some View {
		TagListView(tags: ["alice", "bob", "carol", "charlie", "dave", "ellen", "frank"].map(\.capitalized))
				.frame(height: 32)
	}
}
