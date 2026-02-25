// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public extension Gemstone.SwapperSwapResult {
    func map() throws -> Primitives.SwapResult {
        Primitives.SwapResult(
            status: status.map(),
            metadata: try metadata?.map()
        )
    }
}

public extension Gemstone.SwapperSwapStatus {
    func map() -> Primitives.SwapStatus {
        switch self {
        case .pending: .pending
        case .completed: .completed
        case .failed: .failed
        }
    }
}

public extension Gemstone.SwapperTransactionSwapMetadata {
    func map() throws -> Primitives.TransactionSwapMetadata {
        Primitives.TransactionSwapMetadata(
            fromAsset: try AssetId(id: fromAsset),
            fromValue: fromValue,
            toAsset: try AssetId(id: toAsset),
            toValue: toValue,
            provider: provider
        )
    }
}
