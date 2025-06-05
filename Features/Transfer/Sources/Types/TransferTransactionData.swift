// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct TransferTransactionData: Sendable {
    public let rates: [FeeRate]
    public let transactionData: TransactionData

    public init(
        allRates: [FeeRate],
        transactionData: TransactionData
    ) {
        self.rates = allRates
        self.transactionData = transactionData
    }
}
