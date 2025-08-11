// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public final class NumberIncrementer {
    private var value: Int
    
    public init(_ initialValue: Int) {
        self.value = initialValue
    }
    
    public func next() -> Int {
        let current = value
        value += 1
        return current
    }
}
