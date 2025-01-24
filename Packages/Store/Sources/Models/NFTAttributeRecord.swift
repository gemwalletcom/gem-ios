// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

struct NFTAttributeRecord: Codable, FetchableRecord, PersistableRecord {
    var assetId: String
    var name: String
    var value: String
    var percentage: Double?
    
    static let asset = belongsTo(NFTAssetRecord.self)
}

extension NFTAttributeRecord: CreateTable {
    
    static let databaseTableName = "nft_attributes"
    
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTAttribute.assetId.name, .text)
                .notNull()
                .references(NFTAssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.NFTAttribute.name.name, .text)
                .notNull()
            $0.column(Columns.NFTAttribute.value.name, .text)
                .notNull()
            $0.column(Columns.NFTAttribute.percentage.name, .double)
            $0.uniqueKey([
                Columns.NFTAttribute.assetId.name,
                Columns.NFTAttribute.name.name,
                Columns.NFTAttribute.value.name
            ])
        }
    }
}

extension NFTAttributeRecord {
    func mapToNFTAttribute() -> NFTAttribute {
        NFTAttribute(
            name: name,
            value: value,
            percentage: percentage
        )
    }
}

extension NFTAttribute {
    func record(for assetId: String) -> NFTAttributeRecord {
        NFTAttributeRecord(
            assetId: assetId,
            name: name,
            value: value,
            percentage: percentage
        )
    }
}
