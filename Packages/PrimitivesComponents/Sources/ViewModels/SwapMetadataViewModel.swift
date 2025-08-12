// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct SwapMetadataViewModel: Sendable {
    let metadata: TransactionExtendedMetadata

    public init(metadata: TransactionExtendedMetadata) {
        self.metadata = metadata
    }

    var headerInput: SwapHeaderInput? {
        guard
            case let .swap(swapMetadata) = metadata.transactionMetadata,
            let fromAsset = metadata.asset(for: swapMetadata.fromAsset),
            let toAsset = metadata.asset(for: swapMetadata.toAsset) else {
            return .none
        }
        
        return SwapHeaderInput(
            from: AssetValuePrice(
                asset: fromAsset,
                value: BigInt(stringLiteral: swapMetadata.fromValue),
                price: metadata.price(for: swapMetadata.fromAsset)
            ),
            to: AssetValuePrice(
                asset: toAsset,
                value: BigInt(stringLiteral: swapMetadata.toValue),
                price: metadata.price(for: swapMetadata.toAsset)
            )
        )
    }
}
