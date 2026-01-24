// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct YieldStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func getPosition(walletId: WalletId, assetId: AssetId) throws -> YieldPositionRecord? {
        try db.read { db in
            try YieldPositionRecord
                .filter(YieldPositionRecord.Columns.walletId == walletId.id)
                .filter(YieldPositionRecord.Columns.assetId == assetId.identifier)
                .fetchOne(db)
        }
    }

    public func getPositions(walletId: WalletId) throws -> [YieldPositionRecord] {
        try db.read { db in
            try YieldPositionRecord
                .filter(YieldPositionRecord.Columns.walletId == walletId.id)
                .fetchAll(db)
        }
    }

    public func updatePosition(_ record: YieldPositionRecord) throws {
        try db.write { db in
            try record.upsert(db)
        }
    }

    public func deletePosition(walletId: WalletId, assetId: AssetId) throws {
        try db.write { db in
            try YieldPositionRecord
                .filter(YieldPositionRecord.Columns.walletId == walletId.id)
                .filter(YieldPositionRecord.Columns.assetId == assetId.identifier)
                .deleteAll(db)
        }
    }

    public func deletePositions(walletId: WalletId) throws {
        try db.write { db in
            try YieldPositionRecord
                .filter(YieldPositionRecord.Columns.walletId == walletId.id)
                .deleteAll(db)
        }
    }
}
