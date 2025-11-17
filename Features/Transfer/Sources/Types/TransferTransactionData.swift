// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct TransferTransactionData: Sendable {
    public let rates: [FeeRate]
    public let transactionData: TransactionData
    public let scanResult: ScanTransaction?

    public init(
        allRates: [FeeRate],
        transactionData: TransactionData,
        scanResult: ScanTransaction? = nil
    ) {
        self.rates = allRates
        self.transactionData = transactionData
        self.scanResult = scanResult
    }
}
