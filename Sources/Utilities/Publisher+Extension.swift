//
//  Publisher+Extension.swift
//
//  Created by Yumenosuke Koukata on 2023/01/14.
//

import Combine

extension Publisher {
	public func manyMap<T>(_ transform: @escaping (Output.Element) -> T) -> Publishers.Map<Self, [T]> where Output: Sequence {
		map { $0.map(transform) }
	}
}
