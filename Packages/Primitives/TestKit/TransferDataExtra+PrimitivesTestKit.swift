// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public extension TransferDataExtra {
    static func mock(
        to: String = "",
        gasLimit: BigInt? = nil,
        gasPrice: GasPriceType? = nil,
        data: Data? = nil,
        outputType: TransferDataOutputType = .encodedTransaction,
        outputAction: TransferDataOutputAction = .send
    ) -> TransferDataExtra {
        TransferDataExtra(
            to: to,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            data: data,
            outputType: outputType,
            outputAction: outputAction
        )
    }
}
