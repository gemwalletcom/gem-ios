// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct MarketAssetRecord: Codable, FetchableRecord, PersistableRecord  {
    
    enum Columns {
        public static let tag = Column("tag")
        public static let assetId = Column("assetId")
    }
    
    public static let databaseTableName: String = "markets_assets"

    public var tag: AssetTag
    public var assetId: AssetId
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
