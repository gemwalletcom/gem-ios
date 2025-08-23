// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Keystore

public struct TransactionSigner: TransactionSigneable {
    private let keystore: any Keystore

    public init(keystore: any Keystore) {
        self.keystore = keystore
    }

    public func sign(
        transfer: TransferData,
        transactionData: TransactionData,
        amount: TransferAmount,
        wallet: Wallet
    ) throws -> [String] {

        let signer = Signer(wallet: wallet, keystore: keystore)
        let fee = Fee(
            fee: amount.networkFee,
            gasPriceType: transactionData.fee.gasPriceType,
            gasLimit: transactionData.fee.gasLimit,
            options: transactionData.fee.options
        )

        let input = SignerInput(
            type: transfer.type,
            asset: transfer.type.asset,
            value: amount.value,
            fee: fee,
            isMaxAmount: amount.useMaxAmount,
            memo: transfer.recipientData.recipient.memo,
            senderAddress: try wallet.account(for: transfer.type.chain).address,
            destinationAddress: transfer.recipientData.recipient.address,
            metadata: transactionData.metadata
        )

        return try signer.sign(input: input)
    }
}
