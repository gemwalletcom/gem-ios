// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct AssetRateFormatter {
    
    private let formatter: ValueFormatter
    
    public init(
        formatter: ValueFormatter = ValueFormatter.full
    ) {
        self.formatter = formatter
    }
    
    //TODO: Add rate direction. from/to
    public func rate(fromAsset: Asset, toAsset: Asset, fromValue: BigInt, toValue: BigInt) throws -> String {
        let fromAmount = try formatter.double(from: fromValue, decimals: fromAsset.decimals.asInt)
        let toAmount = try formatter.double(from: toValue, decimals: toAsset.decimals.asInt)
        let amount = toAmount / fromAmount
        
        let amountString = CurrencyFormatter(type: .currency).string(
            double: amount,
            symbol: toAsset.symbol
        )
        return String("1 \(fromAsset.symbol) ≈ \(amountString)")
    }
}
