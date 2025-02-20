// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct SwapMetadataViewModel: Sendable {
    let metadata: SwapMetadata

    public init(metadata: SwapMetadata) {
        self.metadata = metadata
    }

    private var transactionMetadata: TransactionSwapMetadata {
        metadata.transactionMetadata
    }

    var headerInput: SwapHeaderInput? {
        guard
            let fromAsset = metadata.asset(for: transactionMetadata.fromAsset),
            let toAsset = metadata.asset(for: transactionMetadata.toAsset) else {
            return .none
        }
        
        return SwapHeaderInput(
            from: SwapAssetInput(
                asset: fromAsset,
                value: BigInt(stringLiteral: transactionMetadata.fromValue),
                price: metadata.price(for: transactionMetadata.fromAsset)
            ),
            to: SwapAssetInput(
                asset: toAsset,
                value: BigInt(stringLiteral: transactionMetadata.toValue),
                price: metadata.price(for: transactionMetadata.toAsset)
            )
        )
    }
}
