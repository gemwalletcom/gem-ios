// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ConfigStore: Sendable {
    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func update(_ config: ConfigResponse) throws {
        try db.write { db in
            try config.record.upsert(db)
        }
    }

    public func get() throws -> ConfigResponse? {
        try db.read { db in
            try ConfigRecord.fetchOne(db)?.config
        }
    }
}
