// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct FiatTransactionStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func addTransactions(walletId: WalletId, transactions: [FiatTransactionInfo]) throws {
        guard transactions.isNotEmpty else { return }
        try db.write { db in
            for transaction in transactions {
                try transaction.record(walletId: walletId.id).upsert(db)
            }
        }
    }
}
