// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public extension Primitives.SignerInput {
    func map() throws -> GemTransactionLoadInput {
        GemTransactionLoadInput(
            inputType: try type.map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            value: value.description,
            gasPrice: fee.gasPriceType.map(),
            memo: memo,
            isMaxValue: useMaxAmount,
            metadata: metadata.map()
        )
    }
}
