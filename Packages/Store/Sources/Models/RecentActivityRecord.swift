// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct RecentActivityRecord: Codable, PersistableRecord, FetchableRecord, TableRecord {
    public static let databaseTableName = "recent_activities"

    public enum Columns {
        static let assetId = Column("assetId")
        static let walletId = Column("walletId")
        static let type = Column("type")
        static let timestamp = Column("timestamp")
    }

    public var assetId: AssetId
    public var walletId: String
    public var type: RecentActivityType
    public var timestamp: Date

    public init(
        assetId: AssetId,
        walletId: String,
        type: RecentActivityType,
        timestamp: Date = Date()
    ) {
        self.assetId = assetId
        self.walletId = walletId
        self.type = type
        self.timestamp = timestamp
    }
}

extension RecentActivityRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.type.name, .text)
                .notNull()
            $0.column(Columns.timestamp.name, .datetime)
                .notNull()
            $0.primaryKey([Columns.assetId.name, Columns.walletId.name, Columns.type.name])
        }
    }
}
