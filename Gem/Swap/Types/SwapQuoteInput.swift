// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

struct SwapQuoteInput: Hashable, Sendable {
    let fromAsset: Asset
    let toAsset: Asset
    let amount: BigInt
}

// MARK: - Identifiable

extension SwapQuoteInput: Identifiable {
    var id: String {
        [fromAsset.id.identifier, toAsset.id.identifier, amount.description]
            .compactMap { $0 }
            .joined(separator: "_")
    }
}

extension SwapQuoteInput {
    static func create(
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
