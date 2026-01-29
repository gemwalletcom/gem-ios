// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct MarketStore: Sendable {

    let db: DatabaseQueue
    
    init(db: DB) {
        self.db = db.dbQueue
    }

    func addAssets(assets: MarketsAssets)  throws {
        try db.write { db in
            for asset in assets.assets {
                try asset.upsert(db)
            }
        }
    }

    func clear() throws -> Int {
        try db.write {
            try MarketAssetRecord
                .deleteAll($0)
        }
    }
}

extension MarketsAssets {
    var assets: [MarketAssetRecord] {
        [
            trending.map {
                MarketAssetRecord(tag: .trending, assetId: $0)
            },
            gainers.map {
                MarketAssetRecord(tag: .gainers, assetId: $0)
            },
            losers.map {
                MarketAssetRecord(tag: .losers, assetId: $0)
            },
            
        ].flatMap { $0 }
    }
}
