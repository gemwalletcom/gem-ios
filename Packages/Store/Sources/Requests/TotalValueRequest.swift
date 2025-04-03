// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TotalValueRequest: ValueObservationQueryable {
    public static var defaultValue: Double { 0 }

    public var walletId: String
    
    public init(walletId: String) {
        self.walletId = walletId
    }

    public func fetch(_ db: Database) throws -> Double {
        try AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .joining(required: AssetRecord.balance
                .filter(Columns.Balance.walletId == walletId)
                .filter(Columns.Balance.isEnabled == true)
            )
            .asRequest(of: AssetRecordInfoMinimal.self)
            .fetchAll(db)
            .map { $0.totalFiatAmount }
            .reduce(0, +)
    }
}
