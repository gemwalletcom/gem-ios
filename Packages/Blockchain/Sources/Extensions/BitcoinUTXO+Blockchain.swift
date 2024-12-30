// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension BitcoinUTXO {
    func mapToUTXO(address: String) -> UTXO {
        return UTXO(
            transaction_id: txid,
            vout: vout,
            value: value,
            address: address
        )
    }
}
