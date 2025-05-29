// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct TransferTransactionData: Sendable {
    public let rates: [FeeRate]
    public let transactionLoad: TransactionLoad

    public init(
        allRates: [FeeRate],
        transactionLoad: TransactionLoad
    ) {
        self.rates = allRates
        self.transactionLoad = transactionLoad
    }
}
