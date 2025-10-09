// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt

extension GemTransactionLoadInput {
    public func map() throws -> TransactionInput {
        return TransactionInput(
            type: try inputType.map(),
            asset: try inputType.getAsset().map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            value: try BigInt.from(string: value),
            balance: BigInt.zero, // Would need to be provided from context
            gasPrice: try gasPrice.map(),
            memo: memo,
            metadata: try self.metadata.map()
        )
    }
}

extension TransactionInput {
    public func map() throws -> GemTransactionLoadInput {
        GemTransactionLoadInput(
            inputType: try self.type.map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            value: value.description,
            gasPrice: gasPrice.map(),
            memo: memo,
            isMaxValue: feeInput.isMaxAmount,
            metadata: self.metadata.map() 
        )
    }
}
