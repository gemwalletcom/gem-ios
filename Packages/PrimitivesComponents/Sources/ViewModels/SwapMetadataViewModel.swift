// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct SwapMetadataViewModel: Sendable {
    let metadata: SwapMetadata

    public init(metadata: SwapMetadata) {
        self.metadata = metadata
    }

    var transactionMetada: TransactionSwapMetadata {
        metadata.transactionMetadata
    }

    var from: SwapAssetInput? {
        guard let fromAsset = metadata.assets.first(where: { $0.id == transactionMetada.fromAsset }) else { return .none }
        return SwapAssetInput(
            asset: fromAsset,
            value: BigInt(stringLiteral: transactionMetada.fromValue),
            price: metadata.assetPrices.first(where: { $0.assetId == transactionMetada.fromAsset.identifier })?.mapToPrice()
        )
    }

    var to: SwapAssetInput? {
        guard let toAsset = metadata.assets.first(where: { $0.id == transactionMetada.toAsset }) else { return .none }
        return SwapAssetInput(
            asset: toAsset,
            value: BigInt(stringLiteral: transactionMetada.toValue),
            price: metadata.assetPrices.first(where: { $0.assetId == transactionMetada.toAsset.identifier })?.mapToPrice()
        )
    }

    var headerInput: SwapHeaderInput? {
        guard let from, let to else { return .none }
        return SwapHeaderInput(
            from: from,
            to: to
        )
    }
}
