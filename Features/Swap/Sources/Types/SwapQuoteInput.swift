// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct SwapQuoteInput: Hashable, Sendable {
    public let fromAsset: Asset
    public let toAsset: Asset
    public let amount: BigInt
}

// MARK: - Identifiable

extension SwapQuoteInput: Identifiable {
    public var id: String {
        [fromAsset.id.identifier, toAsset.id.identifier, amount.description]
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
        guard let fromAsset = fromAsset?.asset else {
            throw SwapQuoteInputError.missingFromAsset
        }
        guard let toAsset = toAsset?.asset else {
            throw SwapQuoteInputError.missingToAsset
        }

        return SwapQuoteInput(
            fromAsset: fromAsset,
            toAsset: toAsset,
            amount: try formatter.format(
                inputValue: fromValue,
                decimals: fromAsset.decimals.asInt
            )
        )
    }
}
