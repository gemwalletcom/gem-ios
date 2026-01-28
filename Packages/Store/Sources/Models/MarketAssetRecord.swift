// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

struct MarketAssetRecord: Codable, FetchableRecord, PersistableRecord  {
    
    enum Columns {
        static let tag = Column("tag")
        static let assetId = Column("assetId")
    }
    
    static let databaseTableName: String = "markets_assets"

    var tag: AssetTag
    var assetId: AssetId
}

extension MarketAssetRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.tag.name, .text)
                .notNull()
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .notNull()
            $0.uniqueKey([
                Columns.tag.name,
                Columns.assetId.name,
            ])
        }
    }
}
