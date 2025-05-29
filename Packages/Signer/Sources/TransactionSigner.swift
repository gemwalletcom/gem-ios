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
        transactionLoad: TransactionLoad,
        amount: TransferAmount,
        wallet: Wallet
    ) throws -> [String] {

        let signer = Signer(wallet: wallet, keystore: keystore)
        let fee = Fee(
            fee: amount.networkFee,
            gasPriceType: transactionLoad.fee.gasPriceType,
            gasLimit: transactionLoad.fee.gasLimit,
            options: transactionLoad.fee.options
        )

        let input = SignerInput(
            type: transfer.type,
            asset: transfer.type.asset,
            value: amount.value,
            fee: fee,
            isMaxAmount: amount.useMaxAmount,
            chainId: transactionLoad.chainId,
            memo: transfer.recipientData.recipient.memo,
            accountNumber: transactionLoad.accountNumber,
            sequence: transactionLoad.sequence,
            senderAddress: try wallet.account(for: transfer.type.chain).address,
            destinationAddress: transfer.recipientData.recipient.address,
            data: transactionLoad.data,
            block: transactionLoad.block,
            token: transactionLoad.token,
            utxos: transactionLoad.utxos,
            messageBytes: transactionLoad.messageBytes,
            extra: transactionLoad.extra
        )

        return try signer.sign(input: input)
    }
}
