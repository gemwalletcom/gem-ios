// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import GRDB
import Primitives
import BigInt

public struct AssetSearchRecord: Codable, PersistableRecord, FetchableRecord, TableRecord  {
    
    public var query: String
    public var assetId: AssetId
    public var priority: Int
    
    public static let databaseTableName: String = "assets_search"
}

extension AssetSearchRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.AssetSearch.query.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.AssetSearch.assetId.name, .text)
                .indexed()
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.AssetSearch.priority.name, .integer)
                .notNull()
            $0.uniqueKey([Columns.AssetSearch.query.name, Columns.AssetSearch.assetId.name])
        }
    }
}
