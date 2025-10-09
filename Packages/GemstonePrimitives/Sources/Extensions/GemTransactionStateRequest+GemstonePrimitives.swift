// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Gemstone

extension TransactionStateRequest {
    public func map() -> GemTransactionStateRequest {
        GemTransactionStateRequest(
            id: id,
            senderAddress: senderAddress,
            createdAt: Int64(createdAt.timeIntervalSince1970),
            blockNumber: Int64(block)
        )
    }
}