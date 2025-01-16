// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Primitives
import Combine

public struct NFTRequest: ValueObservationQueryable {
    public static var defaultValue: [NFTData] { [] }
    
    private let walletId: String
    private let collectionId: String?
    
    public init(
        walletId: String,
        collectionId: String?
    ) {
        self.walletId = walletId
        self.collectionId = collectionId
    }
    
    public func fetch(_ db: Database) throws -> [NFTData] {
        let collectionRecords = try NFTCollectionRecord
            .fetchAll(db, sql: """
            SELECT * FROM \(NFTCollectionRecord.databaseTableName)
            WHERE id IN (
                SELECT collectionId 
                FROM \(NFTAssetRecord.databaseTableName) 
                WHERE walletId = ?
            )
            \(collectionId != nil ? "AND id = ?" : "")
            """, arguments: collectionId != nil ? [walletId, collectionId] : [walletId]
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
