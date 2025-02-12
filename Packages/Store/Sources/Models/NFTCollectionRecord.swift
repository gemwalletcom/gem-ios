// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

struct NFTCollectionRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var description: String?
    var chain: Chain
    var contractAddress: String
    var isVerified: Bool
    var links: [AssetLink]?

    var imageUrl: String
    var previewImageUrl: String

    static let assets = hasMany(NFTAssetRecord.self).forKey("assets")
}

extension NFTCollectionRecord: CreateTable {

    static let databaseTableName = "nft_collections"

    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTCollection.id.name, .text)
                .primaryKey()
            $0.column(Columns.NFTCollection.name.name, .text).notNull()
            $0.column(Columns.NFTCollection.description.name, .text)
            $0.column(Columns.NFTCollection.chain.name, .text).notNull()
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.NFTCollection.contractAddress.name, .text).notNull()
            $0.column(Columns.NFTCollection.isVerified.name, .boolean).notNull()
            $0.column(Columns.NFTCollection.links.name, .jsonText)
            $0.column(Columns.NFTCollection.imageUrl.name, .text)
            $0.column(Columns.NFTCollection.previewImageUrl.name, .text)
        }
    }
}

extension NFTCollection {
    func record() -> NFTCollectionRecord {
        NFTCollectionRecord(
            id: id,
            name: name,
            description: description,
            chain: chain,
            contractAddress: contractAddress,
            isVerified: isVerified,
            links: links,
            imageUrl: image.imageUrl,
            previewImageUrl: image.previewImageUrl
        )
    }
}
