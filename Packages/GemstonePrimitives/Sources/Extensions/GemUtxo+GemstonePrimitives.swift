// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public extension GemUtxo {
    func map() throws -> UTXO {
        UTXO(
            transaction_id: transactionId,
            vout: vout,
            value: value,
            address: address
        )
    }
}

public extension UTXO {
    func map() -> GemUtxo {
        GemUtxo(
            transactionId: transaction_id,
            vout: vout,
            value: value,
            address: address
        )
    }
}
