// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Primitives
import SwapService

extension SwapQuoteInput: Identifiable {
    public var id: String {
        [fromAsset.id.identifier, toAsset.id.identifier, value.description]
            .compactMap { $0 }
            .joined(separator: "_")
    }
}

extension SwapQuoteInput {
    public static func create(
        fromAsset: AssetData?,
        toAsset: AssetData?,
        fromValue: String,
        formatter: SwapValueFormatter
    ) throws -> SwapQuoteInput {
        guard let fromAsset else {
            throw SwapQuoteInputError.missingFromAsset
        }
        guard let toAsset = toAsset?.asset else {
            throw SwapQuoteInputError.missingToAsset
        }

        let value = try formatter.format(
            inputValue: fromValue,
            decimals: fromAsset.asset.decimals.asInt
        )
        let useMaxAmount = value == fromAsset.balance.available

        return SwapQuoteInput(
            fromAsset: fromAsset.asset,
            toAsset: toAsset,
            value: value,
            useMaxAmount: useMaxAmount
        )
    }
}
