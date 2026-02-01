// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

struct MinimumAccountReserveValidator<V>: ValueValidator where V: ValueValidatable & SignedNumeric {

    private let available: V
    private let requiredReserve: V
    private let asset: Asset

    init(available: V, reserve: V, asset: Asset) {
        self.available = available
        self.requiredReserve = reserve
        self.asset = asset
    }

    func validate(_ value: V) throws {
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

    var id: String { "MinAccountReserveValidator<\(asset.symbol)>" }
}
