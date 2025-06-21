// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletConnector

public struct TransferConfirmationInput: Sendable {
    public let data: TransferData
    public let wallet: Wallet
    public let transactionData: TransactionData
    public let amount: TransferAmount
    public let delegate: TransferDataCallback.ConfirmTransferDelegate?

    public init(
        data: TransferData,
        wallet: Wallet,
        transactionData: TransactionData,
        amount: TransferAmount,
        delegate: TransferDataCallback.ConfirmTransferDelegate?
    ) {
        self.data = data
        self.wallet = wallet
        self.transactionData = transactionData
        self.amount = amount
        self.delegate = delegate
    }
}
