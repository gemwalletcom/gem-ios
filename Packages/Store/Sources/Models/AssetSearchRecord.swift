// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

internal import BigInt

struct AssetSearchRecord: Codable, PersistableRecord, FetchableRecord, TableRecord  {
    
    static let databaseTableName: String = "assets_search"
    
    enum Columns {
        static let query = Column("query")
        static let assetId = Column("assetId")
        static let priority = Column("priority")
    }

    var query: String
    var assetId: AssetId
    var priority: Int
}

extension AssetSearchRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.query.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.assetId.name, .text)
                .indexed()
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.priority.name, .integer)
                .notNull()
            $0.uniqueKey([Columns.query.name, Columns.assetId.name])
        }
    }
}
