//
//  Binding+Extension.swift
//
//  Created by Yumenosuke Koukata on 2023/01/12.
//

import SwiftUI

func ==<T: Equatable>(lhs: Binding<T?>, rhs: T) -> Binding<Bool> {
	.init {
		lhs.wrappedValue == rhs
	} set: { value in
		lhs.wrappedValue = value ? rhs : nil
	}
}
