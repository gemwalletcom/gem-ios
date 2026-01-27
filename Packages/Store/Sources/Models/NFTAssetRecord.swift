// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

struct NFTAssetRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "nft_assets"

    struct Columns {
        static let id = Column("id")
        static let collectionId = Column("collectionId")
        static let contractAddress = Column("contractAddress")
        static let tokenId = Column("tokenId")
        static let tokenType = Column("tokenType")
        static let name = Column("name")
        static let description = Column("description")
        static let chain = Column("chain")
        static let attributes = Column("attributes")
        static let resourceUrl = Column("resourceUrl")
        static let resourceMimeType = Column("resourceMimeType")
        static let previewImageUrl = Column("previewImageUrl")
        static let previewImageMimeType = Column("previewImageMimeType")
    }

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
    

    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.id.name, .text)
                .primaryKey()
            $0.column(Columns.contractAddress.name, .text)
            $0.column(Columns.tokenId.name, .text).notNull()
            $0.column(Columns.tokenType.name, .text).notNull()
            $0.column(Columns.name.name, .text).notNull()
            $0.column(Columns.description.name, .text)
            $0.column(Columns.chain.name, .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.collectionId.name, .text)
                .notNull()
                .indexed()
                .references(NFTCollectionRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.attributes.name, .jsonText)
            $0.column(Columns.resourceUrl.name, .text)
                .notNull()
            $0.column(Columns.resourceMimeType.name, .text)
                .notNull()
            $0.column(Columns.previewImageUrl.name, .text)
                .notNull()
            $0.column(Columns.previewImageMimeType.name, .text)
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
