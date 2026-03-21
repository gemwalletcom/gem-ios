// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct FiatTransactionsRequest: DatabaseQueryable {

    public let walletId: WalletId

    public init(walletId: WalletId) {
        self.walletId = walletId
    }

    public func fetch(_ db: Database) throws -> [FiatTransactionInfo] {
        try FiatTransactionRecord
            .filter(FiatTransactionRecord.Columns.walletId == walletId.id)
            .fetchAll(db)
            .map { $0.fiatTransactionInfo }
    }
}
