// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct PriceRecord: Codable, FetchableRecord, PersistableRecord  {
    public static let databaseTableName: String = "prices"
    
    enum Columns {
        static let assetId = Column("assetId")
        static let price = Column("price")
        static let priceChangePercentage24h = Column("priceChangePercentage24h")
        static let marketCap = Column("marketCap")
        static let marketCapFdv = Column("marketCapFdv")
        static let marketCapRank = Column("marketCapRank")
        static let totalVolume = Column("totalVolume")
        static let circulatingSupply = Column("circulatingSupply")
        static let totalSupply = Column("totalSupply")
        static let maxSupply = Column("maxSupply")
    }

    public var assetId: AssetId
    public var price: Double
    public var priceChangePercentage24h: Double
    
    public var marketCap: Double?
    public var marketCapFdv: Double?
    public var marketCapRank: Int?
    public var totalVolume: Double?
    public var circulatingSupply: Double?
    public var totalSupply: Double?
    public var maxSupply: Double?
}

extension PriceRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.assetId.name, .text)
                .primaryKey()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.price.name, .numeric)
            $0.column(Columns.priceChangePercentage24h.name, .numeric)
            
            $0.column(Columns.marketCap.name, .double)
            $0.column(Columns.marketCapFdv.name, .double)
            $0.column(Columns.marketCapRank.name, .integer)
            $0.column(Columns.totalVolume.name, .double)
            $0.column(Columns.circulatingSupply.name, .double)
            $0.column(Columns.totalSupply.name, .double)
            $0.column(Columns.maxSupply.name, .double)
        }
    }
}

extension PriceRecord: Identifiable {
    public var id: String { assetId.identifier }
}

extension AssetPrice {
    var record: PriceRecord {
        return PriceRecord(
            assetId: try! AssetId(id: assetId),
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
            assetId: assetId.identifier,
            price: price,
            priceChangePercentage24h: priceChangePercentage24h
        )
    }
    
    func mapToMarket() -> AssetMarket {
        AssetMarket(
            marketCap: marketCap,
            marketCapFdv: marketCapFdv,
            marketCapRank: marketCapRank?.asInt32,
            totalVolume: totalVolume,
            circulatingSupply: circulatingSupply,
            totalSupply: totalSupply,
            maxSupply: maxSupply
        )
    }
}
