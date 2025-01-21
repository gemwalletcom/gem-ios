import Foundation
import Primitives
@preconcurrency import GRDB

// MARK: - NFTCollectionRecord

struct NFTCollectionRecord: Codable, FetchableRecord, PersistableRecord {
    var walletId: String
    var id: String
    var name: String
    var description: String?
    var chain: Chain
    var contractAddress: String
    var isVerified: Bool

    static let assets = hasMany(NFTAssetRecord.self).forKey("assets")
    static let image = hasOne(NFTCollectionImageRecord.self).forKey("image")
}

extension NFTCollectionRecord: CreateTable {

    static let databaseTableName = "nft_collections"

    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTCollection.walletId.name, .text).notNull()
            $0.column(Columns.NFTCollection.id.name, .text).primaryKey()
            $0.column(Columns.NFTCollection.name.name, .text).notNull()
            $0.column(Columns.NFTCollection.description.name, .text)
            $0.column(Columns.NFTCollection.chain.name, .text).notNull()
            $0.column(Columns.NFTCollection.contractAddress.name, .text).notNull()
            $0.column(Columns.NFTCollection.isVerified.name, .boolean).notNull()
        }
    }
}

extension NFTCollection {
    func record(for walletId: String) -> NFTCollectionRecord {
        NFTCollectionRecord(
            walletId: walletId,
            id: id,
            name: name,
            description: description,
            chain: chain,
            contractAddress: contractAddress,
            isVerified: isVerified
        )
    }
}

// MARK: - NFTAssetRecord

struct NFTAssetRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var collectionId: String
    var tokenId: String
    var tokenType: NFTType
    var name: String
    var description: String?
    var chain: Chain

    static let collection = belongsTo(NFTCollectionRecord.self)
    static let image = hasOne(NFTImageRecord.self).forKey("image")
    static let attributes = hasMany(NFTAttributeRecord.self).forKey("attributes")
}

extension NFTAssetRecord: CreateTable {
    
    static let databaseTableName = "nft_assets"

    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTAsset.id.name, .text).primaryKey()
            $0.column(Columns.NFTAsset.tokenId.name, .text).notNull()
            $0.column(Columns.NFTAsset.tokenType.name, .text).notNull()
            $0.column(Columns.NFTAsset.name.name, .text).notNull()
            $0.column(Columns.NFTAsset.description.name, .text)
            $0.column(Columns.NFTAsset.chain.name, .text).notNull()
            $0.column(Columns.NFTAsset.collectionId.name, .text)
                .references(NFTCollectionRecord.databaseTableName, onDelete: .cascade)
        }
    }
}

extension NFTAsset {
    func record() -> NFTAssetRecord {
        NFTAssetRecord(
            id: id,
            collectionId: collectionId,
            tokenId: tokenId,
            tokenType: tokenType,
            name: name,
            description: description,
            chain: chain
        )
    }
}

// MARK: - NFTAttributeRecord

struct NFTAttributeRecord: Codable, FetchableRecord, PersistableRecord {
    var assetId: String
    var name: String
    var value: String
    
    static let asset = belongsTo(NFTAssetRecord.self)
}

extension NFTAttributeRecord: CreateTable {
    
    static let databaseTableName = "nft_attributes"
    
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTAttribute.name.name, .text).notNull()
            $0.column(Columns.NFTAttribute.value.name, .text).notNull()
            $0.column(Columns.NFTAttribute.assetId.name, .text)
                .notNull()
                .references(NFTAssetRecord.databaseTableName, onDelete: .cascade)
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
            value: value
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

// MARK: - NFTImageRecord

struct NFTImageRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var imageUrl: String
    var previewImageUrl: String
    var originalSourceUrl: String
    
    static let asset = belongsTo(NFTAssetRecord.self)
}

extension NFTImageRecord: CreateTable {
    
    static let databaseTableName = "nft_images"

    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTImage.imageUrl.name, .text).notNull()
            $0.column(Columns.NFTImage.previewImageUrl.name, .text).notNull()
            $0.column(Columns.NFTImage.originalSourceUrl.name, .text).notNull()
            $0.column(Columns.NFTImage.id.name, .text).notNull()
                .references(NFTAssetRecord.databaseTableName, onDelete: .cascade)
        }
    }
}

extension NFTImageRecord {
    func mapToNFTImage() -> NFTImage {
        NFTImage(
            imageUrl: imageUrl,
            previewImageUrl: previewImageUrl,
            originalSourceUrl: originalSourceUrl
        )
    }
}

extension NFTImage {
    func nftRecord(for id: String) -> NFTImageRecord {
        NFTImageRecord(
            id: id,
            imageUrl: imageUrl,
            previewImageUrl: previewImageUrl,
            originalSourceUrl: originalSourceUrl
        )
    }
    
    func collectionRecord(for id: String) -> NFTCollectionImageRecord {
        NFTCollectionImageRecord(
            id: id,
            imageUrl: imageUrl,
            previewImageUrl: previewImageUrl,
            originalSourceUrl: originalSourceUrl
        )
    }
}

// MARK: - NFTCollectionImageRecord

struct NFTCollectionImageRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var imageUrl: String
    var previewImageUrl: String
    var originalSourceUrl: String

    static let collection = belongsTo(NFTCollectionRecord.self)
}

extension NFTCollectionImageRecord: CreateTable {
    
    static let databaseTableName = "nft_collection_images"
    
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTImage.imageUrl.name, .text).notNull()
            $0.column(Columns.NFTImage.previewImageUrl.name, .text).notNull()
            $0.column(Columns.NFTImage.originalSourceUrl.name, .text).notNull()
            $0.column(Columns.NFTImage.id.name, .text).notNull()
                .references(NFTCollectionRecord.databaseTableName, onDelete: .cascade)
        }
    }
}

extension NFTCollectionImageRecord {
    func mapToNFTImage() -> NFTImage {
        NFTImage(
            imageUrl: imageUrl,
            previewImageUrl: previewImageUrl,
            originalSourceUrl: originalSourceUrl
        )
    }
}
