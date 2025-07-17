// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TransactionRequest: ValueObservationQueryable {
    public static var defaultValue: TransactionExtended? { nil }

    private let walletId: String
    private let transactionId: String

    public var filters: [TransactionsRequestFilter] = []

    public init(
        walletId: String,
        transactionId: String
    ) {
        self.walletId = walletId
        self.transactionId = transactionId
    }

    public func fetch(_ db: Database) throws -> TransactionExtended? {
        try TransactionsRequest.fetch(
            db,
            type: .transaction(id: transactionId),
            filters: filters,
            walletId: walletId,
            limit: 1
        ).first
    }
}
