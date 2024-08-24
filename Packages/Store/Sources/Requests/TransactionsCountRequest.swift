// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TransactionsCountRequest: Queryable {
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

    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<Int, Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    private func fetch(_ db: Database) throws -> Int {
        return try TransactionRecord
            .filter(Columns.Transaction.walletId == walletId)
            .filter(Columns.Transaction.state == state.rawValue)
            .fetchCount(db)
    }
}
