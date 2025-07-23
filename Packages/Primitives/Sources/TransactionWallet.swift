// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionWallet: Sendable {
    public let transaction: Transaction
    public let wallet: Wallet

    public init(transaction: Transaction, wallet: Wallet) {
        self.transaction = transaction
        self.wallet = wallet
    }
}
