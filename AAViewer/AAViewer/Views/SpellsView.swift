//
//  TagView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import Combine
import Foundation
import SwiftUI

struct SpellsView: View {
	@State var spells: [Spell] = []

	var body: some View {
		Text(spells
			.sorted { rhs, lhs in
				rhs.enhanced > lhs.enhanced
			}
			.reduce(into: AttributedString(), { accum, spell in
				accum.append(AttributedString(spell.phrase, attributes: .init([
					.font: NSFont.systemFont(ofSize: .maximum(8, 12 + CGFloat(spell.enhanced * 2))),
					.foregroundColor: NSColor.white,
					.backgroundColor: NSColor(seed: spell.phrase),
				])))
				guard spells.last != spell else {
					accum.append(AttributedString(" "))
					return
				}
				accum.append(AttributedString("   "))
			}))
	}

	private func item(for text: String) -> some View {
		Text(text)
			.padding(.all, 5)
			.font(.footnote)
			.background(Color.blue)
			.foregroundColor(Color.white)
			.cornerRadius(30)
	}
}

struct SpellsView_Previews: PreviewProvider {
	static var previews: some View {
		SpellsView()
	}
}
