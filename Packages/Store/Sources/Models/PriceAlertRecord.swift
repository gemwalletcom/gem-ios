// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct PriceAlertRecord: Codable, FetchableRecord, PersistableRecord  {
    public static let databaseTableName: String = "price_alerts"
    
    public enum Columns {
        static let id = Column("id")
        static let assetId = Column("assetId")
        static let currency = Column("currency")
        static let priceDirection = Column("priceDirection")
        static let price = Column("price")
        static let pricePercentChange = Column("pricePercentChange")
        static let lastNotifiedAt = Column("lastNotifiedAt")
    }

    public var id: String
    public var assetId: AssetId
    public var currency: String
    public var priceDirection: PriceAlertDirection?
    public var price: Double?
    public var pricePercentChange: Double?

    public var lastNotifiedAt: Date?
}

extension PriceAlertRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.id.name, .text)
                .primaryKey()
            $0.column(Columns.assetId.name, .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.currency.name, .text)
            $0.column(Columns.priceDirection.name, .text)
            $0.column(Columns.price.name, .double)
            $0.column(Columns.pricePercentChange.name, .double)
            $0.column(Columns.lastNotifiedAt.name, .date)
        }
    }
}

extension PriceAlertRecord {
    func map() -> PriceAlert {
        PriceAlert(
            assetId: assetId,
            currency: currency,
            price: price,
            pricePercentChange: pricePercentChange,
            priceDirection: priceDirection,
            lastNotifiedAt: lastNotifiedAt
        )
    }
}

extension PriceAlert {
    func mapToRecord() -> PriceAlertRecord {
        PriceAlertRecord(
            id: id,
            assetId: assetId,
            currency: currency,
            priceDirection: priceDirection,
            price: price,
            pricePercentChange: pricePercentChange,
            lastNotifiedAt: lastNotifiedAt
        )
    }
}
