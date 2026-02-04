// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct EarnStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func getPositions(walletId: WalletId, assetId: AssetId) throws -> [EarnPosition] {
        try db.read { db in
            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
                .fetchAll(db)
                .compactMap { $0.earnPosition }
        }
    }

    public func getPosition(walletId: WalletId, assetId: AssetId, provider: String) throws -> EarnPosition? {
        try db.read { db in
            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
                .filter(EarnPositionRecord.Columns.provider == provider)
                .fetchOne(db)?
                .earnPosition
        }
    }

    public func updatePosition(_ position: EarnPosition, walletId: WalletId) throws {
        try db.write { db in
            try position.record(walletId: walletId.id).upsert(db)
        }
    }

    public func updatePositions(_ positions: [EarnPosition], walletId: WalletId) throws {
        try db.write { db in
            for position in positions {
                try position.record(walletId: walletId.id).upsert(db)
            }
        }
    }

    public func deletePosition(walletId: WalletId, assetId: AssetId, provider: String) throws {
        try db.write { db in
            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
                .filter(EarnPositionRecord.Columns.provider == provider)
                .deleteAll(db)
        }
    }

    @discardableResult
    public func clear() throws -> Int {
        try db.write { db in
            return try EarnPositionRecord.deleteAll(db)
        }
    }
}
