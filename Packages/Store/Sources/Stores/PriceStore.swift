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
                    .filter(PriceRecord.Columns.assetId == assetPrice.assetId)
                    .updateAll(
                        db,
                        PriceRecord.Columns.price.set(to: assetPrice.price),
                        PriceRecord.Columns.priceChangePercentage24h.set(to: assetPrice.priceChangePercentage24h)
                    )
            }
        }
    }
    
    @discardableResult
    public func updateMarket(assetId: String, market: AssetMarket) throws -> Int {
        try db.write { db in
            try PriceRecord
                .filter(PriceRecord.Columns.assetId == assetId)
                .updateAll(
                    db,
                    PriceRecord.Columns.marketCap.set(to: market.marketCap),
                    PriceRecord.Columns.marketCapRank.set(to: market.marketCapRank),
                    PriceRecord.Columns.totalVolume.set(to: market.totalVolume),
                    PriceRecord.Columns.circulatingSupply.set(to: market.circulatingSupply),
                    PriceRecord.Columns.totalSupply.set(to: market.totalSupply),
                    PriceRecord.Columns.maxSupply.set(to: market.maxSupply)
                )
        }
    }
    
    public func getPrices(for assetIds: [String]) throws -> [AssetPrice] {
        try db.read { db in
            try PriceRecord
                .filter(assetIds.contains(PriceRecord.Columns.assetId))
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
