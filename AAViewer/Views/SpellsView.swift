//
//  TagView.swift
//  AAViewer
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//

import SwiftUI

struct SpellsView: View {
	@State var spells: [Spell]

	var body: some View {
		var width = CGFloat.zero
		var height = CGFloat.zero

		return ZStack(alignment: .topLeading) {
			ForEach(spells, id: \.self) { spell in
				Text(spell.phrase)
					.padding(.all, 4)
					.font(.system(size: 12 * pow(1.2, CGFloat(spell.enhanced))))
					.background(Color(seed: spell.phrase))
					.foregroundColor(.white)
					.cornerRadius(30)
					.padding(.all, 4)
					.alignmentGuide(.leading, computeValue: { d in
						if abs(width - d.width) > 330 {
							width = 0
							height -= d.height
						}
						let result = width
						if spell == spells.last {
							width = 0
						} else {
							width -= d.width
						}
						return result
					})
					.alignmentGuide(.top, computeValue: { _ in
						let result = height
						if spell == spells.last {
							height = 0
						}
						return result
					})
			}
		}
	}
}

struct SpellsView_Previews: PreviewProvider {
	static var previews: some View {
		SpellsView(spells: [
			.init(phrase: "Bar", enhanced: 3),
			.init(phrase: "Foo", enhanced: 2),
			.init(phrase: "Bar", enhanced: 1),
			.init(phrase: "Foo", enhanced: 0),
			.init(phrase: "Bar", enhanced: -1),
			.init(phrase: "Foo", enhanced: -2),
			.init(phrase: "Bar", enhanced: -3),
		])
	}
}
