// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt

extension GemTransferDataExtra {
    public func map() throws -> TransferDataExtra {
        return TransferDataExtra(
            to: to,
            gasLimit: try gasLimit.map { try BigInt.from(string: $0) },
            gasPrice: try gasPrice?.map(),
            data: data,
            outputType: outputType.map(),
            outputAction: outputAction.map()
        )
    }
}

extension TransferDataExtra {
    public func map() -> GemTransferDataExtra {
        return GemTransferDataExtra(
            to: to,
            gasLimit: gasLimit?.description,
            gasPrice: gasPrice?.map(),
            data: data,
            outputType: outputType.map(),
            outputAction: outputAction.map()
        )
    }
}
