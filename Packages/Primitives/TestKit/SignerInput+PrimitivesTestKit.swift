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
        chainId: String = "",
        memo: String? = nil,
        accountNumber: Int = 0,
        sequence: Int = 0,
        senderAddress: String = "0x1234567890123456789012345678901234567890",
        destinationAddress: String = "0x1234567890123456789012345678901234567890",
        data: SigningData = .none,
        block: SignerInputBlock = SignerInputBlock(hash: ""),
        token: SignerInputToken = SignerInputToken(),
        utxos: [UTXO] = [],
        messageBytes: String = ""
    ) -> SignerInput {
        SignerInput(
            type: type,
            asset: asset,
            value: value,
            fee: fee,
            isMaxAmount: isMaxAmount,
            chainId: chainId,
            memo: memo,
            accountNumber: accountNumber,
            sequence: sequence,
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            data: data,
            block: block,
            token: token,
            utxos: utxos,
            messageBytes: messageBytes
        )
    }
}