// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension WCEthereumTransaction {
    static func mock() -> WCEthereumTransaction {
        WCEthereumTransaction(
            chainId: nil,
            from: .empty,
            to: .empty,
            value: nil,
            gas: nil,
            gasLimit: nil,
            gasPrice: nil,
            maxFeePerGas: nil,
            maxPriorityFeePerGas: nil,
            nonce: nil,
            data: nil
        )
    }
}
