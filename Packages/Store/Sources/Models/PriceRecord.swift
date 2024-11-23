// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct PriceRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "prices"

    public var assetId: String
    public var price: Double
    public var priceChangePercentage24h: Double
    
    public var marketCap: Double?
    public var marketCapRank: Int?
    public var totalVolume: Double?
    public var circulatingSupply: Double?
    public var totalSupply: Double?
    public var maxSupply: Double?
}

extension PriceRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.Price.assetId.name, .text)
                .primaryKey()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.Price.price.name, .numeric)
            $0.column(Columns.Price.priceChangePercentage24h.name, .numeric)
            
            $0.column(Columns.Price.marketCap.name, .double)
            $0.column(Columns.Price.marketCapRank.name, .integer)
            $0.column(Columns.Price.totalVolume.name, .double)
            $0.column(Columns.Price.circulatingSupply.name, .double)
            $0.column(Columns.Price.totalSupply.name, .double)
            $0.column(Columns.Price.maxSupply.name, .double)
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
    
    func mapToMarket() -> AssetMarket {
        AssetMarket(
            marketCap: marketCap,
            marketCapRank: marketCapRank?.asInt32,
            totalVolume: totalVolume,
            circulatingSupply: circulatingSupply,
            totalSupply: totalSupply,
            maxSupply: maxSupply
        )
    }
}
