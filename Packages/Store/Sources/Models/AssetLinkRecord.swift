// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives
import BigInt

public struct AssetLinkRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "assets_links"
    
    public var assetId: String
    public var name: String
    public var url: String
}

extension AssetLinkRecord: Identifiable {
    public var id: String { assetId }
}

extension AssetLinkRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.AssetLink.assetId.name, .text)
                .references(AssetRecord.databaseTableName, onDelete: .cascade)

            $0.column(Columns.AssetLink.name.name, .text)
            $0.column(Columns.AssetLink.url.name, .text)
            
            $0.uniqueKey([Columns.AssetLink.assetId.name, Columns.AssetLink.name.name])
        }
    }
}

extension AssetLink {
    func record(assetId: String) -> AssetLinkRecord {
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
