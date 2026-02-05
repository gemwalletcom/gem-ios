// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct PercentageSuggestionsFormatter: Sendable {

    public init() {}

    public func suggestions(for price: Double) -> [Int] {
        let base = base(for: price)
        return [base, base * 2, base * 3]
    }

    private func base(for price: Double) -> Int {
        switch price {
        case ..<100: 5
        case ..<10000: 3
        default: 2
        }
    }
}
