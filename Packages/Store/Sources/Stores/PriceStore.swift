// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PriceStore: Sendable {
    
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func updatePrice(price: AssetPrice) throws {
        try updatePrices(prices: [price])
    }
    
    public func updatePrices(prices: [AssetPrice]) throws {
        try db.write { db in
            for assetPrice in prices {
                try assetPrice.record.insert(db, onConflict: .ignore)
                try PriceRecord
                    .filter(Columns.Price.assetId == assetPrice.assetId)
                    .updateAll(db,
                        Columns.Price.price.set(to: assetPrice.price),
                        Columns.Price.priceChangePercentage24h.set(to: assetPrice.priceChangePercentage24h)
                    )
            }
        }
    }
    
    @discardableResult
    public func updateMarket(assetId: String, market: AssetMarket) throws -> Int {
        try db.write { db in
            try PriceRecord
                .filter(Columns.Price.assetId == assetId)
                .updateAll(db,
                    Columns.Price.marketCap.set(to: market.marketCap),
                    Columns.Price.marketCapRank.set(to: market.marketCapRank),
                    Columns.Price.totalVolume.set(to: market.totalVolume),
                    Columns.Price.circulatingSupply.set(to: market.circulatingSupply),
                    Columns.Price.totalSupply.set(to: market.totalSupply),
                    Columns.Price.maxSupply.set(to: market.maxSupply)
                )
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
