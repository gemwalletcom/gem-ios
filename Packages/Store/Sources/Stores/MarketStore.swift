// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct MarketStore: Sendable {

    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func addAssets(assets: MarketsAssets)  throws {
        try db.write { db in
            for asset in assets.assets {
                try asset.upsert(db)
            }
        }
    }

    public func clear() throws -> Int {
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
