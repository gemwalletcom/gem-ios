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
        walletId: WalletId,
        type: RecentActivityType
    ) throws {
        try db.write { db in
            try RecentActivityRecord(
                assetId: assetId,
                walletId: walletId.id,
                type: type,
                timestamp: Date()
            ).upsert(db)
        }
    }
}
