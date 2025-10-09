// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PerpetualPositionRecord: Codable, TableRecord, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "perpetuals_positions"
    
    public struct Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let perpetualId = Column("perpetualId")
        static let assetId = Column("assetId")
        static let size = Column("size")
        static let sizeValue = Column("sizeValue")
        static let leverage = Column("leverage")
        static let entryPrice = Column("entryPrice")
        static let liquidationPrice = Column("liquidationPrice")
        static let marginType = Column("marginType")
        static let direction = Column("direction")
        static let marginAmount = Column("marginAmount")
        static let takeProfit = Column("takeProfit")
        static let stopLoss = Column("stopLoss")
        static let pnl = Column("pnl")
        static let funding = Column("funding")
        static let updatedAt = Column("updatedAt")
    }
    
    public var id: String
    public var walletId: String
    public var perpetualId: String
    public var assetId: AssetId
    public var size: Double
    public var sizeValue: Double
    public var leverage: Int
    public var entryPrice: Double?
    public var liquidationPrice: Double?
    public var marginType: PerpetualMarginType
    public var direction: PerpetualDirection
    public var marginAmount: Double
    public var takeProfit: PerpetualTriggerOrder?
    public var stopLoss: PerpetualTriggerOrder?
    public var pnl: Double
    public var funding: Float?
    public var updatedAt: Date
    
    public init(
        id: String,
        walletId: String,
        perpetualId: String,
        assetId: AssetId,
        size: Double,
        sizeValue: Double,
        leverage: Int,
        entryPrice: Double?,
        liquidationPrice: Double?,
        marginType: PerpetualMarginType,
        direction: PerpetualDirection,
        marginAmount: Double,
        takeProfit: PerpetualTriggerOrder?,
        stopLoss: PerpetualTriggerOrder?,
        pnl: Double,
        funding: Float? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.walletId = walletId
        self.perpetualId = perpetualId
        self.assetId = assetId
        self.size = size
        self.sizeValue = sizeValue
        self.leverage = leverage
        self.entryPrice = entryPrice
        self.liquidationPrice = liquidationPrice
        self.marginType = marginType
        self.direction = direction
        self.marginAmount = marginAmount
        self.takeProfit = takeProfit
        self.stopLoss = stopLoss
        self.pnl = pnl
        self.funding = funding
        self.updatedAt = updatedAt
    }
    
    // MARK: - Associations
    
    static let perpetual = belongsTo(PerpetualRecord.self, using: ForeignKey([Columns.perpetualId]))
}

extension PerpetualPositionRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.column(Columns.id.name, .text).notNull()
            $0.column(Columns.walletId.name, .text).notNull().indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.perpetualId.name, .text).notNull()
                .references(PerpetualRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.assetId.name, .jsonText).notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.size.name, .double).notNull()
            $0.column(Columns.sizeValue.name, .double).notNull()
            $0.column(Columns.leverage.name, .integer).notNull()
            $0.column(Columns.entryPrice.name, .double)
            $0.column(Columns.liquidationPrice.name, .double)
            $0.column(Columns.marginType.name, .text).notNull()
            $0.column(Columns.direction.name, .text).notNull()
            $0.column(Columns.marginAmount.name, .double).notNull()
            $0.column(Columns.takeProfit.name, .jsonText)
            $0.column(Columns.stopLoss.name, .jsonText)
            $0.column(Columns.pnl.name, .double).notNull()
            $0.column(Columns.funding.name, .double)
            $0.column(Columns.updatedAt.name, .date).notNull()
            $0.uniqueKey([
                Columns.id.name,
                Columns.walletId.name,
            ])
        }
    }
}

// MARK: - Mapping

extension PerpetualPositionRecord {
    func mapToPerpetualPosition() -> PerpetualPosition {
        return PerpetualPosition(
            id: id,
            perpetualId: perpetualId,
            assetId: assetId,
            size: size,
            sizeValue: sizeValue,
            leverage: UInt8(leverage),
            entryPrice: entryPrice,
            liquidationPrice: liquidationPrice,
            marginType: marginType,
            direction: direction,
            marginAmount: marginAmount,
            takeProfit: takeProfit,
            stopLoss: stopLoss,
            pnl: pnl,
            funding: funding
        )
    }
}

extension PerpetualPosition {
    func record(walletId: String) -> PerpetualPositionRecord {
        return PerpetualPositionRecord(
            id: id,
            walletId: walletId,
            perpetualId: perpetualId,
            assetId: assetId,
            size: size,
            sizeValue: sizeValue,
            leverage: Int(leverage),
            entryPrice: entryPrice,
            liquidationPrice: liquidationPrice,
            marginType: marginType,
            direction: direction,
            marginAmount: marginAmount,
            takeProfit: takeProfit,
            stopLoss: stopLoss,
            pnl: pnl,
            funding: funding
        )
    }
}
