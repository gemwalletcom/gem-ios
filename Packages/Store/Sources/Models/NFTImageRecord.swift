import Foundation
import Primitives
@preconcurrency import GRDB

// MARK: - Records

struct NFTImageRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var imageUrl: String
    var previewImageUrl: String
    var originalSourceUrl: String
    
    static let databaseTableName = "nft_image"
}

struct NFTAttributeRecord: Codable, FetchableRecord, PersistableRecord {
    var assetId: String // Foreign Key to NFTAssetRecord
    var name: String
    var value: String
    
    static let databaseTableName = "nft_attribute"

    static let asset = belongsTo(NFTAssetRecord.self)
}

struct NFTAssetRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var collectionId: String // Foreign Key to NFTCollectionRecord
    var tokenId: String
    var tokenType: NFTType
    var name: String
    var description: String?
    var chain: Chain
    var imageId: String? // Foreign Key to NFTImageRecord

    static let databaseTableName = "nft_asset"

    static let collection = belongsTo(NFTCollectionRecord.self)
    static let image = belongsTo(NFTImageRecord.self)
    static let attributes = hasMany(NFTAttributeRecord.self)
}

struct NFTCollectionRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var walletId: String
    var name: String
    var description: String?
    var chain: Chain
    var contractAddress: String
    var imageId: String // Foreign Key to NFTImageRecord
    var isVerified: Bool

    static let databaseTableName = "nft_collection"

    static let image = belongsTo(NFTImageRecord.self)
    static let assets = hasMany(NFTAssetRecord.self)
}

// MARK: - Database Migrations

extension Database {
    func setupNFTSchema() throws {
        try create(table: NFTImageRecord.databaseTableName) { t in
            t.column("id", .text).notNull().primaryKey()
            t.column("imageUrl", .text).notNull()
            t.column("previewImageUrl", .text).notNull()
            t.column("originalSourceUrl", .text).notNull()
        }

        try create(table: NFTCollectionRecord.databaseTableName) { t in
            t.column("id", .text).primaryKey()
            t.column("walletId", .text)
            t.column("name", .text).notNull()
            t.column("description", .text)
            t.column("chain", .text).notNull()
            t.column("contractAddress", .text).notNull()
            t.column("imageId", .text).references(NFTImageRecord.databaseTableName, onDelete: .cascade)
            t.column("isVerified", .boolean).notNull()
        }

        try create(table: NFTAssetRecord.databaseTableName) { t in
            t.column("id", .text).primaryKey()
            t.column("collectionId", .text).references(NFTCollectionRecord.databaseTableName, onDelete: .cascade)
            t.column("tokenId", .text).notNull()
            t.column("tokenType", .text).notNull()
            t.column("name", .text).notNull()
            t.column("description", .text)
            t.column("chain", .text).notNull()
            t.column("imageId", .text).references(NFTImageRecord.databaseTableName, onDelete: .cascade)
        }

        try create(table: NFTAttributeRecord.databaseTableName) { t in
            t.column("assetId", .text).references(NFTAssetRecord.databaseTableName, onDelete: .cascade).primaryKey()
            t.column("name", .text).notNull()
            t.column("value", .text).notNull()
        }
    }
}

// MARK: - Extensions to Map to Database Records

extension NFTImage {
    func record(for id: String) -> NFTImageRecord {
        NFTImageRecord(
            id: id,
            imageUrl: imageUrl,
            previewImageUrl: previewImageUrl,
            originalSourceUrl: originalSourceUrl
        )
    }
}

extension NFTAttribute {
    func record(for assetId: String) -> NFTAttributeRecord {
        NFTAttributeRecord(
            assetId: assetId,
            name: name,
            value: value
        )
    }
}

extension NFTAsset {
    func record(for collectionId: String, imageId: String) -> NFTAssetRecord {
        NFTAssetRecord(
            id: id,
            collectionId: collectionId,
            tokenId: tokenId,
            tokenType: tokenType,
            name: name,
            description: description,
            chain: chain,
            imageId: imageId
        )
    }
}

extension NFTCollection {
    func record(walletId: String, imageId: String) -> NFTCollectionRecord {
        NFTCollectionRecord(
            id: id,
            walletId: walletId,
            name: name,
            description: description,
            chain: chain,
            contractAddress: contractAddress,
            imageId: imageId,
            isVerified: isVerified
        )
    }
}

// MARK: - Extensions to Map from Database Records

extension NFTImageRecord {
    func mapToNFTImage() -> NFTImage {
        NFTImage(
            imageUrl: imageUrl,
            previewImageUrl: previewImageUrl,
            originalSourceUrl: originalSourceUrl
        )
    }
}

extension NFTAttributeRecord {
    func mapToNFTAttribute() -> NFTAttribute {
        NFTAttribute(
            name: name,
            value: value
        )
    }
}

extension NFTAssetRecord {
    func mapToNFTAsset(image: NFTImage, attributes: [NFTAttribute]) -> NFTAsset {
        NFTAsset(
            id: id,
            collectionId: collectionId,
            tokenId: tokenId,
            tokenType: tokenType,
            name: name,
            description: description,
            chain: chain,
            image: image,
            attributes: attributes
        )
    }
}

extension NFTCollectionRecord {
    func mapToNFTCollection(image: NFTImage, assets: [NFTAsset]) -> NFTCollection {
        NFTCollection(
            id: id,
            name: name,
            description: description,
            chain: chain,
            contractAddress: contractAddress,
            image: image,
            isVerified: isVerified
        )
    }
}
