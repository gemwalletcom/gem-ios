import Foundation
import GRDB
import Primitives

public struct NFTStore: Sendable {
    private let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func addOrUpdateNFTResults(_ data: [NFTData], for walletId: String) throws {
        try db.write { db in
            try deleteAllRecords(for: walletId, db: db)
            
            for nftData in data {
                let collectionImageRecord = nftData.collection.image.record(for: nftData.collection.id)
                try collectionImageRecord.save(db)
                let collectionRecord = nftData.collection.record(walletId: walletId, imageId: collectionImageRecord.id)
                try collectionRecord.save(db)
                
                for asset in nftData.assets {
                    let assetImageRecord = asset.image.record(for: asset.id)
                    try assetImageRecord.save(db)
                    
                    let assetRecord = asset.record(for: collectionRecord.id, imageId: assetImageRecord.id)
                    try assetRecord.save(db)
                    
                    for attribute in asset.attributes {
                        let attributeRecord = attribute.record(for: assetRecord.id)
                        try attributeRecord.save(db)
                    }
                }
            }
        }
    }
    
    public func getNFTResults(for walletId: String) throws -> [NFTData] {
        try db.read { db in
            let collectionRecords = try NFTCollectionRecord
                .fetchAll(db, sql: """
                SELECT * FROM nft_collection 
                WHERE id IN (
                    SELECT collectionId 
                    FROM nft_asset 
                    WHERE walletId = ?
                )
                """, arguments: [walletId]
                )
            
            return try collectionRecords.map { collectionRecord in
                let collectionImageRecord = try NFTImageRecord.fetchOne(db, key: collectionRecord.imageId)
                guard let collectionImage = collectionImageRecord?.mapToNFTImage() else {
                    throw DatabaseError(message: "Image not found for collection: \(collectionRecord.id)")
                }
                
                let assetRecords = try NFTAssetRecord
                    .filter(sql: "collectionId = ?", arguments: [collectionRecord.id])
                    .fetchAll(db)
                
                let assets = try assetRecords.map { assetRecord -> NFTAsset in
                    let assetImageRecord = try NFTImageRecord.fetchOne(db, key: assetRecord.imageId)
                    guard let assetImage = assetImageRecord?.mapToNFTImage() else {
                        throw DatabaseError(message: "Image not found for asset: \(assetRecord.id)")
                    }
                    
                    let attributeRecords = try NFTAttributeRecord
                        .filter(sql: "assetId = ?", arguments: [assetRecord.id])
                        .fetchAll(db)
                    let attributes = attributeRecords.map { $0.mapToNFTAttribute() }
                    
                    return assetRecord.mapToNFTAsset(image: assetImage, attributes: attributes)
                }
                
                let collection = collectionRecord.mapToNFTCollection(image: collectionImage, assets: assets)
                return NFTData(collection: collection, assets: assets)
            }
        }
    }
    
    private func deleteAllRecords(for walletId: String, db: Database) throws {
        try NFTCollectionRecord
            .filter(sql: "walletId = ?", arguments: [walletId])
            .deleteAll(db)
        
        try NFTAssetRecord
            .filter(sql: """
                    collectionId IN (
                        SELECT id FROM nft_collection WHERE walletId = ?
                    )
                """, arguments: [walletId])
            .deleteAll(db)
        
        try NFTAttributeRecord
            .filter(sql: """
                    assetId IN (
                        SELECT id FROM nft_asset WHERE collectionId IN (
                            SELECT id FROM nft_collection WHERE walletId = ?
                        )
                    )
                """, arguments: [walletId])
            .deleteAll(db)
        
        try NFTImageRecord
            .filter(sql: """
                    id NOT IN (SELECT imageId FROM nft_collection)
                    AND id NOT IN (SELECT imageId FROM nft_asset)
                """)
            .deleteAll(db)
    }
}

