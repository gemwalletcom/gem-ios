// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PriceStore {
    
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func updatePrices(prices: [AssetPrice]) throws {
        try db.write { db in
            for assetPrice in prices {
                try assetPrice.record.upsert(db)
            }
        }
    }
    
    public func getPrices(for assetIds: [String]) throws -> [AssetPrice] {
        try db.read { db in
            try PriceRecord
                .filter(assetIds.contains(Columns.Price.assetId))
                .fetchAll(db)
                .map { $0.mapToAssetPrice() }
        }
    }
    
    public func clear() throws -> Int {
        try db.write {
            try PriceRecord
                .deleteAll($0)
        }
    }
}
