// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public extension SignerInput {
    static func mock(
        type: TransferDataType = .transfer(.mock()),
        asset: Asset = .mock(),
        value: BigInt = .zero,
        fee: Fee = .mock(),
        isMaxAmount: Bool = false,
        memo: String? = nil,
        senderAddress: String = "0x1234567890123456789012345678901234567890",
        destinationAddress: String = "0x1234567890123456789012345678901234567890",
        metadata: TransactionLoadMetadata = .none
    ) -> SignerInput {
        SignerInput(
            type: type,
            asset: asset,
            value: value,
            fee: fee,
            isMaxAmount: isMaxAmount,
            memo: memo,
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            metadata: metadata
        )
    }
}