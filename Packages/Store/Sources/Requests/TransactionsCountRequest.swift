// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TransactionsCountRequest: ValueObservationQueryable {
    public static var defaultValue: Int { 0 }

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
