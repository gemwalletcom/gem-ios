// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct FiatRateStore: Sendable {

    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func add(_ rates: [FiatRate]) throws {
        try db.write { db in
            for rate in rates {
                try rate.record.upsert(db)
            }
        }
    }

    public func clear() throws -> Int {
        try db.write {
            try FiatRateRecord
                .deleteAll($0)
        }
    }
}
