// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct PriceAlertRecord: Codable, FetchableRecord, PersistableRecord  {

    public static let databaseTableName: String = "price_alerts"

    public var id: String
    public var assetId: String
    public var priceDirection: PriceAlertDirection?
    public var price: Double?
    public var pricePercentChange: Double?

    public var lastNotifiedAt: Date?
}

extension PriceAlertRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column("id", .text)
                .primaryKey()
            $0.column("assetId", .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column("priceDirection", .text)
            $0.column("price", .double)
            $0.column("pricePercentChange", .double)
            $0.column("lastNotifiedAt", .date)
        }
    }
}

extension PriceAlertRecord {
    func map() -> PriceAlert {
        PriceAlert(
            assetId: assetId,
            price: price,
            pricePercentChange: pricePercentChange,
            priceDirection: priceDirection
        )
    }
}

extension PriceAlert {
    func mapToRecord() -> PriceAlertRecord {
        PriceAlertRecord(
            id: id,
            assetId: assetId,
            priceDirection: priceDirection,
            price: price,
            pricePercentChange: pricePercentChange
        )
    }
}
