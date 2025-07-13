// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public extension TransactionPreload {
    static func mock(
        blockHash: String = "",
        blockNumber: Int = 0,
        utxos: [UTXO] = [],
        sequence: Int = 0,
        chainId: String = "",
        isDestinationAddressExist: Bool = true
    ) -> TransactionPreload {
        TransactionPreload(
            blockHash: blockHash,
            blockNumber: blockNumber,
            utxos: utxos,
            sequence: sequence,
            chainId: chainId,
            isDestinationAddressExist: isDestinationAddressExist
        )
    }
}