// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct FiatRateRecord: Codable, FetchableRecord, PersistableRecord  {
    public enum Columns {
        public static let symbol = Column("symbol")
        public static let rate = Column("rate")
        public static let updatedAt = Column("updatedAt")
    }

    public static let databaseTableName: String = "fiat_rates"

    public var symbol: String
    public var rate: Double
    public var updatedAt: Date
}

extension FiatRate {
    var record: FiatRateRecord {
        return FiatRateRecord(
            symbol: symbol,
            rate: rate,
            updatedAt: .now
        )
    }
}

extension FiatRateRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.symbol.name, .text)
                .primaryKey()
                .notNull()
                .indexed()
            $0.column(Columns.rate.name, .double)
                .notNull()
            $0.column(Columns.updatedAt.name, .date)
                .notNull()
        }
    }
}
