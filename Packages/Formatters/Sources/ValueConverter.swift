// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct ValueConverter: Sendable {
    private let formatter: ValueFormatter
    
    public init(formatter: ValueFormatter = .medium) {
        self.formatter = formatter
    }
    
    public func convertToFiat(
        amount: String,
        price: AssetPrice
    ) throws -> Decimal {
        let value = try formatter.number(amount: amount)
        return value * Decimal(price.price)
    }

    public func convertToAmount(
        fiatValue: String,
        price: AssetPrice,
        decimals: Int
    ) throws -> String {
        let fiatNumber = try formatter.number(amount: fiatValue)
        let amount = try calculateAssetAmount(fiat: fiatNumber, price: price)
        return try formatAssetAmount(amount: amount, decimals: decimals)
    }
}

// MARK: - Private

extension ValueConverter {
    private func calculateAssetAmount(
        fiat: Decimal,
        price: AssetPrice
    ) throws -> Decimal {
        guard price.price > 0 else {
            throw AnyError("Incorrect price")
        }
        return fiat / Decimal(price.price)
    }

    private func formatAssetAmount(
        amount: Decimal,
        decimals: Int
    ) throws -> String {
        let amount = NSDecimalNumber(decimal: amount).stringValue
        let inputNumber = try formatter.inputNumber(from: amount, decimals: decimals)
        guard !inputNumber.isZero else {
            throw AnyError("Cannot format zero amount")
        }
        return formatter.string(inputNumber, decimals: decimals)
    }
}
