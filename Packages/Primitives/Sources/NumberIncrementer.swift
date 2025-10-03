// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public final class NumberIncrementer<T: FixedWidthInteger> {
    private var value: T

    public init(_ initialValue: T) {
        self.value = initialValue
    }

    @discardableResult
    public func next() -> T {
        let current = value
        value &+= 1 // &+= wrapping on overflow)
        return current
    }

    public func current() -> T {
        value
    }
}
