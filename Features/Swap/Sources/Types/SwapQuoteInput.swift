// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct SwapQuoteInput: Hashable, Sendable {
    public let fromAsset: Asset
    public let toAsset: Asset
    public let value: BigInt
    public let useMaxAmount: Bool
}

// MARK: - Identifiable

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
