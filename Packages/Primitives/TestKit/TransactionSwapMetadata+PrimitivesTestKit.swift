// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension TransactionSwapMetadata {
    static func mock(
        fromAsset: AssetId = .mock(),
        fromValue: String = "",
        toAsset: AssetId = .mock(.smartChain),
        toValue: String = "",
        provider: String? = nil,
        swapResult: SwapResult? = nil
    ) -> TransactionSwapMetadata {
        TransactionSwapMetadata(
            fromAsset: fromAsset,
            fromValue: fromValue,
            toAsset: toAsset,
            toValue: toValue,
            provider: provider,
            swapResult: swapResult
        )
    }
}
