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

    var resourceUrl: String
    var resourceMimeType: String
    
    var previewImageUrl: String
    var previewImageMimeType: String
    
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
            $0.column(Columns.NFTAsset.resourceUrl.name, .text)
                .notNull()
            $0.column(Columns.NFTAsset.resourceMimeType.name, .text)
                .notNull()
            $0.column(Columns.NFTAsset.previewImageUrl.name, .text)
                .notNull()
            $0.column(Columns.NFTAsset.previewImageMimeType.name, .text)
                .notNull()
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
            resourceUrl: resource.url,
            resourceMimeType: resource.mimeType,
            previewImageUrl: images.preview.url,
            previewImageMimeType: images.preview.mimeType
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
            resource: NFTResource(url: resourceUrl, mimeType: resourceMimeType),
            images: NFTImages(
                preview: NFTResource(
                    url: previewImageUrl,
                    mimeType: previewImageMimeType
                )
            ),
            attributes: attributes ?? []
        )
    }
}
