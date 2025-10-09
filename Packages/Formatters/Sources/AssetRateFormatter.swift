// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public struct AssetRateFormatter {
    public enum Direction {
        case direct
        case inverse
    }
    
    private let formatter: ValueFormatter
    
    public init(
        formatter: ValueFormatter = ValueFormatter.full
    ) {
        self.formatter = formatter
    }

    public func rate(
        fromAsset: Asset,
        toAsset: Asset,
        fromValue: BigInt,
        toValue: BigInt,
        direction: Direction = .direct
    ) throws -> String {
        let (baseAsset, quoteAsset, baseValue, quoteValue): (Asset, Asset, BigInt, BigInt) = {
            switch direction {
            case .direct: (fromAsset, toAsset, fromValue, toValue)
            case .inverse: (toAsset, fromAsset, toValue, fromValue)
            }
        }()

        let baseAmount  = try formatter.double(from: baseValue,  decimals: baseAsset.decimals.asInt)
        let quoteAmount = try formatter.double(from: quoteValue, decimals: quoteAsset.decimals.asInt)

        let amount = quoteAmount / baseAmount
        let amountString = CurrencyFormatter(type: .currency, currencyCode: .empty)
            .string(double: amount, symbol: quoteAsset.symbol)

        return "1 \(baseAsset.symbol) ≈ \(amountString)"
    }
}
