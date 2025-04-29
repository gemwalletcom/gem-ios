// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TransactionsCountRequest: ValueObservationQueryable {
    public static var defaultValue: Int { 0 }

    private let walletId: String
    private let state: TransactionState

    public init(
        walletId: String,
        state: TransactionState
    ) {
        self.walletId = walletId
        self.state = state
    }

    public func fetch(_ db: Database) throws -> Int {
        try TransactionRecord
            .filter(TransactionRecord.Columns.walletId == walletId)
            .filter(TransactionRecord.Columns.state == state.rawValue)
            .fetchCount(db)
    }
}
