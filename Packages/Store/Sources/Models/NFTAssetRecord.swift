// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

struct NFTAssetRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var collectionId: String
    var contractAddress: String?
    var tokenId: String
    var tokenType: NFTType
    var name: String
    var description: String?
    var chain: Chain
    var attributes: [NFTAttribute]?

    var imageUrl: String
    var previewImageUrl: String
    
    static let collection = belongsTo(NFTCollectionRecord.self)
    static let assetAssociations = hasMany(NFTAssetAssociationRecord.self)
}

extension NFTAssetRecord: CreateTable {
    
    static let databaseTableName = "nft_assets"

    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTAsset.id.name, .text)
                .primaryKey()
            $0.column(Columns.NFTAsset.contractAddress.name, .text)
            $0.column(Columns.NFTAsset.tokenId.name, .text).notNull()
            $0.column(Columns.NFTAsset.tokenType.name, .text).notNull()
            $0.column(Columns.NFTAsset.name.name, .text).notNull()
            $0.column(Columns.NFTAsset.description.name, .text)
            $0.column(Columns.NFTAsset.chain.name, .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.NFTAsset.collectionId.name, .text)
                .notNull()
                .indexed()
                .references(NFTCollectionRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.NFTAsset.attributes.name, .jsonText)
            $0.column(Columns.NFTCollection.imageUrl.name, .text)
            $0.column(Columns.NFTCollection.previewImageUrl.name, .text)
        }
    }
}

extension NFTAsset {
    func record() -> NFTAssetRecord {
        NFTAssetRecord(
            id: id,
            collectionId: collectionId,
            contractAddress: contractAddress,
            tokenId: tokenId,
            tokenType: tokenType,
            name: name,
            description: description,
            chain: chain,
            attributes: attributes,
            imageUrl: image.imageUrl,
            previewImageUrl: image.previewImageUrl
        )
    }
}

extension NFTAssetRecord {
    func mapToAsset() -> NFTAsset {
        NFTAsset(
            id: id,
            collectionId: collectionId,
            contractAddress: contractAddress,
            tokenId: tokenId,
            tokenType: tokenType,
            name: name,
            description: description,
            chain: chain,
            image: NFTImage(
                imageUrl: imageUrl,
                previewImageUrl: previewImageUrl,
                originalSourceUrl: imageUrl
            ),
            attributes: attributes ?? []
        )
    }
}
