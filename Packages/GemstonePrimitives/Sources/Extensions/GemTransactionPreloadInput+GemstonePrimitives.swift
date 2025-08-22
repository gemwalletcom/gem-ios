// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Gemstone

extension TransactionPreloadInput {
    public func map() -> GemTransactionPreloadInput {
        return GemTransactionPreloadInput(
            asset: asset.map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress
        )
    }
}