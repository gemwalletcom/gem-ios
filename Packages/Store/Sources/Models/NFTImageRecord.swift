import Foundation
import Primitives
@preconcurrency import GRDB

// MARK: - NFTAssetsAssociationRecord

struct NFTAssetAssociationRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: String
    var walletId: String
    var collectionId: String
    var assetId: String
    
    init(walletId: String, collectionId: String, assetId: String) {
        self.id = Self.computedId(walletId: walletId, collectionId: collectionId, assetId: assetId)
        self.walletId = walletId
        self.collectionId = collectionId
        self.assetId = assetId
    }
}

extension NFTAssetAssociationRecord {
    static func computedId(walletId: String, collectionId: String, assetId: String) -> String {
        [walletId, collectionId, assetId].joined(separator: "_")
    }
}

extension NFTAssetAssociationRecord {
    func record() -> NFTAssetAssociationRecord {
        NFTAssetAssociationRecord(
            walletId: walletId,
            collectionId: collectionId,
            assetId: assetId
        )
    }
}

extension NFTAssetAssociationRecord: CreateTable {
    
    static let databaseTableName = NFTAssetRecord.databaseTableName + "_associations"
    
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTAssetsAssociation.id.name, .text)
                .primaryKey()
            $0.column(Columns.NFTAssetsAssociation.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.NFTAssetsAssociation.collectionId.name, .text)
                .notNull()
                .indexed()
                .references(NFTCollectionRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.NFTAssetsAssociation.assetId.name, .text)
                .notNull()
                .indexed()
                .references(NFTAssetRecord.databaseTableName, onDelete: .cascade)
        }
    }
}

// MARK: - NFTCollectionRecord

struct NFTCollectionRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var description: String?
    var chain: Chain
    var contractAddress: String
    var isVerified: Bool
    
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
            imageUrl: image.imageUrl,
            previewImageUrl: image.previewImageUrl
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
    
    var imageUrl: String
    var previewImageUrl: String
    
    static let collection = belongsTo(NFTCollectionRecord.self)
    static let attributes = hasMany(NFTAttributeRecord.self).forKey("attributes")
    static let assetAssociations = hasMany(NFTAssetAssociationRecord.self)
}

extension NFTAssetRecord: CreateTable {
    
    static let databaseTableName = "nft_assets"

    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.NFTAsset.id.name, .text)
                .primaryKey()
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
            tokenId: tokenId,
            tokenType: tokenType,
            name: name,
            description: description,
            chain: chain,
            imageUrl: image.imageUrl,
            previewImageUrl: image.previewImageUrl
        )
    }
}

// MARK: - NFTAttributeRecord

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
            value: value
        )
    }
}

extension NFTAttribute {
    func record(for assetId: String) -> NFTAttributeRecord {
        NFTAttributeRecord(
            assetId: assetId,
            name: name,
            value: value,
            percentage: .none
        )
    }
}
