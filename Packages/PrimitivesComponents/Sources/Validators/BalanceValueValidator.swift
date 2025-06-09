// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct BalanceValueValidator<V>: ValueValidator where V: ValueValidatable {

    private let available: V
    private let asset: Asset

    public init(available: V, asset: Asset) {
        self.available = available
        self.asset = asset
    }

    public func validate(_ value: V) throws {
        guard value <= available else {
            throw TransferAmountCalculatorError.insufficientBalance(asset)
        }
    }

    public var id: String { "BalanceValidator<\(asset.symbol)>" }
}
