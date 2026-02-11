// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public extension Primitives.SignerInput {
    func map() throws -> GemTransactionLoadInput {
        GemTransactionLoadInput(
            inputType: try typeWithGasLimit.map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            value: value.description,
            gasPrice: fee.gasPriceType.map(),
            memo: memo,
            isMaxValue: useMaxAmount,
            metadata: metadata.map()
        )
    }

    private var typeWithGasLimit: TransferDataType {
        guard case .swap(let from, let to, let swapData) = type else { return type }
        let data = swapData.data.withGasLimit(fee.gasLimit.description)
        return .swap(from, to, SwapData(quote: swapData.quote, data: data))
    }
}
