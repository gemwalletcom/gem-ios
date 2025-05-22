// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct BalanceValueValidator<Value>: ValueValidator
where Value: ValueValidetable {

    private let available: Value
    private let asset: Asset

    public init(available: Value, asset: Asset) {
        self.available = available
        self.asset = asset
    }

    public func validate(_ value: Value) throws {
        guard value <= available else {
            throw TransferAmountCalculatorError.insufficientBalance(asset)
        }
    }

    public var id: String { "BalanceValidator<\(asset.symbol)>" }
}
