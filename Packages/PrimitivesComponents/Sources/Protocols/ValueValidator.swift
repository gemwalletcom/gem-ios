// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public typealias ValueValidatable = Comparable & Sendable & ExpressibleByIntegerLiteral

public protocol ValueValidator<Formatted>: Identifiable, Sendable {
    associatedtype Formatted
    func validate(_ value: Formatted) throws
}

extension Comparable where Self: SignedNumeric {
    func isBetween(_ a: Self, and b: Self) -> Bool {
        self >= a && self <= b
    }
}
