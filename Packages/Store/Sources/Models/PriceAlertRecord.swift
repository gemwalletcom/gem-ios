// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct PriceAlertRecord: Codable, FetchableRecord, PersistableRecord  {

    public static let databaseTableName: String = "price_alerts"

    public var id: String
    public var assetId: String
    public var currency: String
    public var priceDirection: PriceAlertDirection?
    public var price: Double?
    public var pricePercentChange: Double?

    public var lastNotifiedAt: Date?
}

extension PriceAlertRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.PriceAlert.id.name, .text)
                .primaryKey()
            $0.column(Columns.PriceAlert.assetId.name, .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.PriceAlert.currency.name, .text)
            $0.column(Columns.PriceAlert.priceDirection.name, .text)
            $0.column(Columns.PriceAlert.price.name, .double)
            $0.column(Columns.PriceAlert.pricePercentChange.name, .double)
            $0.column(Columns.PriceAlert.lastNotifiedAt.name, .date)
        }
    }
}

extension PriceAlertRecord {
    func map() -> PriceAlert {
        PriceAlert(
            assetId: try! AssetId(id: assetId),
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
            assetId: assetId.identifier,
            currency: currency,
            priceDirection: priceDirection,
            price: price,
            pricePercentChange: pricePercentChange,
            lastNotifiedAt: lastNotifiedAt
        )
    }
}
