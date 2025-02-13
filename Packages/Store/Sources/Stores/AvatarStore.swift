// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct AvatarStore: Sendable {
    private let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func save(_ avatar: AvatarValue, for walletId: String) throws {
        try db.write { db in
            try avatar
                .mapToRecord(for: walletId)
                .insert(db, onConflict: .replace)
        }
    }
    
    @discardableResult
    public func remove(for walletId: String) throws -> Int {
        try db.write { db in
            try AvatarValueRecord
                .filter(Columns.Avatar.walletId == walletId)
                .deleteAll(db)
        }
    }
}
