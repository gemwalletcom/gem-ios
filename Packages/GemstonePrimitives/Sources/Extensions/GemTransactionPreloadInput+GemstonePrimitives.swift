// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Gemstone

extension TransactionPreloadInput {
    public func map() -> GemTransactionPreloadInput {
        return GemTransactionPreloadInput(
            inputType: inputType.map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress
        )
    }
}
