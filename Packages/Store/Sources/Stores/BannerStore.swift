// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct BannerStore: Sendable {

    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func addBanner(_ banner: Banner) throws {
        try db.write { db in
            try banner.record.insert(db, onConflict: .ignore)
        }
    }

    public func updateState(_ id: String, state: BannerState) throws -> Int {
        try db.write {
            try BannerRecord
                .filter(Columns.Banner.id == id)
                .updateAll($0, [Columns.Banner.state.set(to: state.rawValue)])
        }
    }

    public func clear() throws -> Int {
        try db.write {
            try BannerRecord
                .deleteAll($0)
        }
    }
}
