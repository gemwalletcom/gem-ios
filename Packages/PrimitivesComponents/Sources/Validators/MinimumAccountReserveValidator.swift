// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public struct MinimumAccountReserveValidator<Value>: ValueValidator
where Value: ValueValidatable & SignedNumeric {

    private let available: Value
    private let requiredReserve: Value
    private let asset: Asset

    public init(available: Value, reserve: Value, asset: Asset) {
        self.available = available
        self.requiredReserve = reserve
        self.asset = asset
    }

    public func validate(_ value: Value) throws {
        guard requiredReserve > 0, asset.type == .native else { return }

        let remaining = available - value

        if remaining.isBetween(1, and: requiredReserve) {
            if let requiredReserve = requiredReserve as? BigInt {
                // TODO: - improve the message
                throw TransferAmountCalculatorError.minimumAccountBalanceTooLow(asset, required: requiredReserve)
            } else {
                throw TransferError.invalidAmount
            }
        }
    }

    public var id: String { "MinAccountReserveValidator<\(asset.symbol)>" }
}
