// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct RecentActivityStore: Sendable {
    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func add(
        assetId: AssetId,
        toAssetId: AssetId?,
        walletId: WalletId,
        type: RecentActivityType,
        createdAt: Date = .now
    ) throws {
        try db.write { db in
            try RecentActivityRecord(
                assetId: assetId,
                toAssetId: toAssetId,
                walletId: walletId.id,
                type: type,
                createdAt: createdAt
            ).insert(db)
        }
    }

    public func clear(walletId: WalletId, types: [RecentActivityType]) throws {
        _ = try db.write { db in
            try RecentActivityRecord
                .filter(RecentActivityRecord.Columns.walletId == walletId.id)
                .filter(types.map { $0.rawValue }.contains(RecentActivityRecord.Columns.type))
                .deleteAll(db)
        }
    }
}
