// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public extension TransferDataExtra {
    static func mock(
        gasLimit: BigInt? = nil,
        gasPrice: GasPriceType? = nil,
        data: Data? = nil,
        outputType: OutputType = .encodedTransaction
    ) -> TransferDataExtra {
        TransferDataExtra(
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            data: data,
            outputType: outputType
        )
    }
}