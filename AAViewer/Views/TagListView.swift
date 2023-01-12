//
//  TagListView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/10.
//

import SwiftUI
import TagKit

struct TagListView: View {
	private let tags: [String]
	private var onTap: ((String) -> Void)? = nil

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
				.onTapGesture { onTap?(tag) }
		}
	}

	@inlinable func onOnTap(perform onTap: @escaping (String) -> Void) -> Self {
		var copied = self
		copied.onTap = onTap
		return copied
	}
}

struct TagListView_Previews: PreviewProvider {
	static var previews: some View {
		TagListView(tags: ["alice", "bob", "carol", "charlie", "dave", "ellen", "frank"].map(\.capitalized))
			.frame(height: 32)
	}
}
