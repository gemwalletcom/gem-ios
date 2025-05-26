// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Keystore

public struct TransactionSigner: TransactionSigning {
    private let keystore: any Keystore

    public init(keystore: any Keystore) {
        self.keystore = keystore
    }

    public func sign(
        transfer: TransferData,
        preload: TransactionLoad,
        amount: TransferAmount,
        wallet: Wallet
    ) throws -> [String] {

        let rawSigner = Signer(wallet: wallet, keystore: keystore)
        let fee = Fee(
            fee: amount.networkFee,
            gasPriceType: preload.fee.gasPriceType,
            gasLimit: preload.fee.gasLimit,
            options: preload.fee.options
        )

        let input = SignerInput(
            type: transfer.type,
            asset: transfer.type.asset,
            value: amount.value,
            fee: fee,
            isMaxAmount: amount.useMaxAmount,
            chainId: preload.chainId,
            memo: transfer.recipientData.recipient.memo,
            accountNumber: preload.accountNumber,
            sequence: preload.sequence,
            senderAddress: try wallet.account(for: transfer.type.chain).address,
            destinationAddress: transfer.recipientData.recipient.address,
            data: preload.data,
            block: preload.block,
            token: preload.token,
            utxos: preload.utxos,
            messageBytes: preload.messageBytes,
            extra: preload.extra
        )

        return try rawSigner.sign(input: input)
    }
}
