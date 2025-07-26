// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PerpetualRecord: Codable, TableRecord, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "perpetuals"
    
    public struct Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let provider = Column("provider")
        static let assetId = Column("assetId")
        static let price = Column("price")
        static let pricePercentChange24h = Column("pricePercentChange24h")
        static let openInterest = Column("openInterest")
        static let volume24h = Column("volume24h")
        static let funding = Column("funding")
        static let leverage = Column("leverage")
    }
    
    public var id: String
    public var name: String
    public var provider: PerpetualProvider
    public var assetId: AssetId
    public var price: Double
    public var pricePercentChange24h: Double
    public var openInterest: Double
    public var volume24h: Double
    public var funding: Double
    public var leverage: Data
    
    public init(
        id: String,
        name: String,
        provider: PerpetualProvider,
        assetId: AssetId,
        price: Double,
        pricePercentChange24h: Double,
        openInterest: Double,
        volume24h: Double,
        funding: Double,
        leverage: Data
    ) {
        self.id = id
        self.name = name
        self.provider = provider
        self.assetId = assetId
        self.price = price
        self.pricePercentChange24h = pricePercentChange24h
        self.openInterest = openInterest
        self.volume24h = volume24h
        self.funding = funding
        self.leverage = leverage
    }
    
    // MARK: - Associations
    
    static let positions = hasMany(PerpetualPositionRecord.self).forKey("positions")
    static let asset = belongsTo(AssetRecord.self, using: ForeignKey(["assetId"], to: ["id"]))
}

extension PerpetualRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) { t in
            t.column(Columns.id.name, .text).primaryKey().notNull()
            t.column(Columns.name.name, .text).notNull()
            t.column(Columns.provider.name, .text).notNull()
            t.column(Columns.assetId.name, .text).notNull()
                .references(AssetRecord.databaseTableName, column: AssetRecord.Columns.id.name, onDelete: .cascade)
            t.column(Columns.price.name, .double).notNull()
            t.column(Columns.pricePercentChange24h.name, .double).notNull()
            t.column(Columns.openInterest.name, .double).notNull()
            t.column(Columns.volume24h.name, .double).notNull()
            t.column(Columns.funding.name, .double).notNull()
            t.column(Columns.leverage.name, .blob).notNull()
        }
    }
}

// MARK: - Mapping

extension PerpetualRecord {
    func mapToPerpetual() -> Perpetual {
        return Perpetual(
            id: id,
            name: name,
            provider: provider,
            assetId: assetId,
            price: price,
            pricePercentChange24h: pricePercentChange24h,
            openInterest: openInterest,
            volume24h: volume24h,
            funding: funding,
            leverage: [UInt8](leverage)
        )
    }
}

extension Perpetual {
    var record: PerpetualRecord {
        return PerpetualRecord(
            id: id,
            name: name,
            provider: provider,
            assetId: assetId,
            price: price,
            pricePercentChange24h: pricePercentChange24h,
            openInterest: openInterest,
            volume24h: volume24h,
            funding: funding,
            leverage: Data(leverage)
        )
    }
}
