// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct PriceRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static var databaseTableName: String = "prices"

    public var assetId: String
    public var price: Double
    public var priceChangePercentage24h: Double
}

extension PriceRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) { t in
            t.column("assetId", .text)
                .primaryKey()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            t.column("price", .numeric)
            t.column("priceChangePercentage24h", .numeric)
        }
    }
}

extension PriceRecord: Identifiable {
    public var id: String { assetId }
}

extension AssetPrice {
    var record: PriceRecord {
        return PriceRecord(
            assetId: assetId,
            price: price,
            priceChangePercentage24h: priceChangePercentage24h
        )
    }
}

extension PriceRecord {
    func mapToPrice() -> Price {
        return Price(
            price: price,
            priceChangePercentage24h: priceChangePercentage24h
        )
    }
    
    func mapToAssetPrice() -> AssetPrice {
        return AssetPrice(
            assetId: assetId,
            price: price,
            priceChangePercentage24h: priceChangePercentage24h
        )
    }
}
