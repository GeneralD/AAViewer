//
//  ColorHash.swift
//  Snippets
//
//  Created by Yumenosuke Koukata on 2023/01/05.
//  Copyright © 2023 ZYXW. All rights reserved.
//

import AppKit
import Foundation

extension NSColor {
	convenience init(seed: String) {
		let values = [0.35, 0.5, 0.65]

		let full: CGFloat = 360

		let seed1: CGFloat = 131
		let seed2: CGFloat = 137
		let maxSafeInteger = 9_007_199_254_740_991 / seed2

		let bkdrHash = seed.compactMap { String($0).unicodeScalars.first?.value }
			.reduce(into: CGFloat(0)) { accum, scl in
				if accum > maxSafeInteger { accum /= seed2 }
				accum *= seed1
				accum += CGFloat(scl)
			}

		let hue = bkdrHash.truncatingRemainder(dividingBy: full - 1.0) / full
		let saturation = values[Int(bkdrHash.truncatingRemainder(dividingBy: CGFloat(values.count)))]
		let brightness = values[Int((bkdrHash / CGFloat(values.count)).truncatingRemainder(dividingBy: CGFloat(values.count)))]

		self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
	}
}
