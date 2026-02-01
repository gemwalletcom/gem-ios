// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

internal import BigInt

struct AssetLinkRecord: Codable, FetchableRecord, PersistableRecord  {
    
    static let databaseTableName: String = "assets_links"
    
    enum Columns {
        static let assetId = Column("assetId")
        static let name = Column("name")
        static let url = Column("url")
    }
    
    var assetId: AssetId
    var name: String
    var url: String
}

extension AssetLinkRecord: Identifiable {
    var id: String { assetId.identifier }
}

extension AssetLinkRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.assetId.name, .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)

            $0.column(Columns.name.name, .text)
            $0.column(Columns.url.name, .text)
            
            $0.uniqueKey([Columns.assetId.name, Columns.name.name])
        }
    }
}

extension AssetLink {
    func record(assetId: AssetId) -> AssetLinkRecord {
        AssetLinkRecord(
            assetId: assetId,
            name: name,
            url: url
        )
    }
}

extension AssetLinkRecord {
    var link: AssetLink {
        AssetLink(name: name, url: url)
    }
}
