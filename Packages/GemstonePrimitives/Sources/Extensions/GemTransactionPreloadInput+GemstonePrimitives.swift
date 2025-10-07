// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Gemstone

extension TransactionPreloadInput {
    public func map() throws -> GemTransactionPreloadInput {
        return GemTransactionPreloadInput(
            inputType: try inputType.map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress
        )
    }
}
