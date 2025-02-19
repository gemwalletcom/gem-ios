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

    var fromValue: BigInt {
        BigInt(stringLiteral: transactionMetada.fromValue)
    }

    var toValue: BigInt {
        BigInt(stringLiteral: transactionMetada.toValue)
    }

    var fromAsset: Asset? {
        metadata.assets.first(where: { $0.id == transactionMetada.fromAsset })
    }

    var toAsset: Asset? {
        metadata.assets.first(where: { $0.id == transactionMetada.toAsset })
    }

    var fromPrice: Price? {
        metadata.assetPrices.first(where: { $0.assetId == transactionMetada.fromAsset.identifier })?.mapToPrice()
    }

    var toPrice: Price? {
        metadata.assetPrices.first(where: { $0.assetId == transactionMetada.toAsset.identifier })?.mapToPrice()
    }

    var headerInput: SwapHeaderInput? {
        guard let fromAsset, let toAsset else { return .none }
        return SwapHeaderInput(
            fromAsset: fromAsset,
            fromValue: fromValue,
            fromPrice: fromPrice,
            toAsset: toAsset,
            toValue: toValue,
            toPrice: toPrice
        )
    }
}
