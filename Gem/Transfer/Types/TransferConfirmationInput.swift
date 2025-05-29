// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletConnector

public struct TransferConfirmationInput: Sendable {
    public let data: TransferData
    public let wallet: Wallet
    public let load: TransactionLoad
    public let amount: TransferAmount
    public let delegate: TransferDataCallback.ConfirmTransferDelegate?

    public init(
        data: TransferData,
        wallet: Wallet,
        load: TransactionLoad,
        amount: TransferAmount,
        delegate: TransferDataCallback.ConfirmTransferDelegate?
    ) {
        self.data = data
        self.wallet = wallet
        self.load = load
        self.amount = amount
        self.delegate = delegate
    }
}
