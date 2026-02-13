// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct TransactionsCountRequest: DatabaseQueryable {

    private let walletId: WalletId
    private let state: TransactionState

    public init(
        walletId: WalletId,
        state: TransactionState
    ) {
        self.walletId = walletId
        self.state = state
    }

    public func fetch(_ db: Database) throws -> Int {
        try TransactionRecord
            .filter(TransactionRecord.Columns.walletId == walletId.id)
            .filter(TransactionRecord.Columns.state == state.rawValue)
            .fetchCount(db)
    }
}

extension TransactionsCountRequest: Equatable {}
