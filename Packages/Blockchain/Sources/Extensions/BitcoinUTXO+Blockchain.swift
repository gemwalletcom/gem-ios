// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension BitcoinUTXO {
    func mapToUTXO() -> UTXO {
        return UTXO(
            transaction_id: txid,
            vout: vout,
            value: value,
            address: .none
        )
    }
}
