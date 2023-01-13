//
//  Sequence+Extension.swift
//
//  Created by Yumenosuke Koukata on 2023/01/14.
//

extension Array {
	func chunked(by size: Int) -> [[Element]] {
		stride(from: 0, to: count, by: size).map {
			.init(self[$0..<Swift.min($0 + size, count)])
		}
	}
}
