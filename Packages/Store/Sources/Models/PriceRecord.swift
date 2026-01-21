// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct PriceRecord: Codable, FetchableRecord, PersistableRecord  {
    public static let databaseTableName: String = "prices"
    
    public enum Columns {
        static let assetId = Column("assetId")
        static let price = Column("price")
        static let priceUsd = Column("priceUsd")
        static let priceChangePercentage24h = Column("priceChangePercentage24h")
        static let marketCap = Column("marketCap")
        static let marketCapFdv = Column("marketCapFdv")
        static let marketCapRank = Column("marketCapRank")
        static let totalVolume = Column("totalVolume")
        static let circulatingSupply = Column("circulatingSupply")
        static let totalSupply = Column("totalSupply")
        static let maxSupply = Column("maxSupply")
        static let allTimeHigh = Column("allTimeHigh")
        static let allTimeHighDate = Column("allTimeHighDate")
        static let allTimeLow = Column("allTimeLow")
        static let allTimeLowDate = Column("allTimeLowDate")
        static let updatedAt = Column("updatedAt")
    }

    public var assetId: AssetId
    public var price: Double
    public var priceUsd: Double
    public var priceChangePercentage24h: Double
    
    public var marketCap: Double?
    public var marketCapFdv: Double?
    public var marketCapRank: Int?
    public var totalVolume: Double?
    public var circulatingSupply: Double?
    public var totalSupply: Double?
    public var maxSupply: Double?
    public var allTimeHigh: Double?
    public var allTimeHighDate: Date?
    public var allTimeLow: Double?
    public var allTimeLowDate: Date?

    public var updatedAt: Date?
}

extension PriceRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.assetId.name, .text)
                .primaryKey()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.price.name, .numeric)
                .notNull()
                .defaults(to: 0)
            $0.column(Columns.priceUsd.name, .numeric)
                .notNull()
                .defaults(to: 0)
            $0.column(Columns.priceChangePercentage24h.name, .numeric)
                .notNull()
                .defaults(to: 0)
            
            $0.column(Columns.marketCap.name, .double)
            $0.column(Columns.marketCapFdv.name, .double)
            $0.column(Columns.marketCapRank.name, .integer)
            $0.column(Columns.totalVolume.name, .double)
            $0.column(Columns.circulatingSupply.name, .double)
            $0.column(Columns.totalSupply.name, .double)
            $0.column(Columns.maxSupply.name, .double)
            $0.column(Columns.allTimeHigh.name, .double)
            $0.column(Columns.allTimeHighDate.name, .date)
            $0.column(Columns.allTimeLow.name, .double)
            $0.column(Columns.allTimeLowDate.name, .date)
            $0.column(Columns.updatedAt.name, .date)
        }
    }
}

extension PriceRecord: Identifiable {
    public var id: String { assetId.identifier }
}

extension AssetPrice {
    var record: PriceRecord {
        return PriceRecord(
            assetId: assetId,
            price: price,
            priceUsd: price,
            priceChangePercentage24h: priceChangePercentage24h
        )
    }
}

extension PriceRecord {
    func mapToPrice() -> Price {
        return Price(
            price: price,
            priceChangePercentage24h: priceChangePercentage24h,
            updatedAt: updatedAt ?? .now
        )
    }
    
    func mapToAssetPrice() -> AssetPrice {
        return AssetPrice(
            assetId: assetId,
            price: price,
            priceChangePercentage24h: priceChangePercentage24h,
            updatedAt: updatedAt ?? .now
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
            maxSupply: maxSupply,
            allTimeHigh: allTimeHigh,
            allTimeHighDate: allTimeHighDate,
            allTimeLow: allTimeLow,
            allTimeLowDate: allTimeLowDate
        )
    }
}
