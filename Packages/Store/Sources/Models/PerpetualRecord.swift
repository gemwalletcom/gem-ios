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
        static let identifier = Column("identifier")
        static let price = Column("price")
        static let pricePercentChange24h = Column("pricePercentChange24h")
        static let openInterest = Column("openInterest")
        static let volume24h = Column("volume24h")
        static let funding = Column("funding")
        static let leverage = Column("leverage")
        static let isPinned = Column("isPinned")
    }
    
    public var id: String
    public var name: String
    public var provider: PerpetualProvider
    public var assetId: AssetId
    public var identifier: String
    public var price: Double
    public var pricePercentChange24h: Double
    public var openInterest: Double
    public var volume24h: Double
    public var funding: Double
    public var leverage: Data
    public var isPinned: Bool
    
    public init(
        id: String,
        name: String,
        provider: PerpetualProvider,
        assetId: AssetId,
        identifier: String,
        price: Double,
        pricePercentChange24h: Double,
        openInterest: Double,
        volume24h: Double,
        funding: Double,
        leverage: Data,
        isPinned: Bool = false
    ) {
        self.id = id
        self.name = name
        self.provider = provider
        self.assetId = assetId
        self.identifier = identifier
        self.price = price
        self.pricePercentChange24h = pricePercentChange24h
        self.openInterest = openInterest
        self.volume24h = volume24h
        self.funding = funding
        self.leverage = leverage
        self.isPinned = isPinned
    }
    
    static let positions = hasMany(PerpetualPositionRecord.self).forKey("positions")
    static let asset = belongsTo(AssetRecord.self, using: ForeignKey(["assetId"], to: ["id"]))
}

extension PerpetualRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.column(Columns.id.name, .text).primaryKey().notNull()
            $0.column(Columns.name.name, .text).notNull()
            $0.column(Columns.provider.name, .text).notNull()
            $0.column(Columns.assetId.name, .text).notNull()
                .references(AssetRecord.databaseTableName, column: AssetRecord.Columns.id.name, onDelete: .cascade)
            $0.column(Columns.identifier.name, .text).notNull()
            $0.column(Columns.price.name, .double).notNull()
            $0.column(Columns.pricePercentChange24h.name, .double).notNull()
            $0.column(Columns.openInterest.name, .double).notNull()
            $0.column(Columns.volume24h.name, .double).notNull()
            $0.column(Columns.funding.name, .double).notNull()
            $0.column(Columns.leverage.name, .blob).notNull()
            $0.column(Columns.isPinned.name, .boolean).notNull().defaults(to: false)
        }
    }
}

extension PerpetualRecord {
    func mapToPerpetual() -> Perpetual {
        return Perpetual(
            id: id,
            name: name,
            provider: provider,
            assetId: assetId,
            identifier: identifier,
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
            identifier: identifier,
            price: price,
            pricePercentChange24h: pricePercentChange24h,
            openInterest: openInterest,
            volume24h: volume24h,
            funding: funding,
            leverage: Data(leverage)
        )
    }
}
