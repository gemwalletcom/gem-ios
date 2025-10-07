// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemTransactionData {
    public func map() throws -> Primitives.TransactionData {
        return TransactionData(
            fee: try fee.map(),
            metadata: try metadata.map()
        )
    }
}
