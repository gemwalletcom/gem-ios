// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemUtxo {
    public func map() throws -> UTXO {
        UTXO(
            transaction_id: transactionId,
            vout: Int32(vout),
            value: value,
            address: address
        )
    }
}

extension UTXO {
    public func map() -> GemUtxo {
        GemUtxo(
            transactionId: transaction_id,
            vout: vout,
            value: value,
            address: address
        )
    }
}
