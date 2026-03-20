// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct FiatTransactionRequest: DatabaseQueryable {

    public let walletId: WalletId
    public let providerId: FiatProviderName
    public let providerTransactionId: String
    private let initialValue: FiatTransaction

    public init(walletId: WalletId, transaction: FiatTransaction) {
        self.walletId = walletId
        self.providerId = transaction.providerId
        self.providerTransactionId = transaction.providerTransactionId
        self.initialValue = transaction
    }

    public func fetch(_ db: Database) throws -> FiatTransaction {
        try FiatTransactionRecord
            .filter(FiatTransactionRecord.Columns.walletId == walletId.id)
            .filter(FiatTransactionRecord.Columns.providerId == providerId.rawValue)
            .filter(FiatTransactionRecord.Columns.providerTransactionId == providerTransactionId)
            .fetchOne(db)?
            .fiatTransaction ?? initialValue
    }
}
