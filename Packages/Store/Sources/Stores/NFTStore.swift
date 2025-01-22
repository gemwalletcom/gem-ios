import Foundation
import GRDB
import Primitives

public struct NFTStore: Sendable {
    private let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    // MARK: - Public methods

    public func save(_ data: [NFTData], for walletId: String) throws {
        try db.write { db in
            let assetsAssociationsRequest = NFTAssetAssociationRecord
                .filter(Columns.NFTAssetsAssociation.walletId == walletId)
            let existingIds = try assetsAssociationsRequest.fetchAll(db).map { $0.id }
            
            var newIds: [String] = []
            
            for nftData in data {
                let collection = nftData.collection
                
                try collection.record().upsert(db)
                
                for asset in nftData.assets {
                    try asset.record().upsert(db)
                    
                    for attribute in asset.attributes {
                        try attribute.record(for: asset.id).upsert(db)
                    }
                    let assetAssociation = NFTAssetAssociationRecord(walletId: walletId, collectionId: collection.id, assetId: asset.id)
                    try assetAssociation.upsert(db)
                    
                    newIds.append(assetAssociation.id)
                }
            }
            
            // delete outdated
            let deletIds = existingIds.asSet().subtracting(newIds.asSet()).asArray()
            try assetsAssociationsRequest
                .filter(deletIds.contains(Columns.NFTAssetsAssociation.id))
                .deleteAll(db)
        }
    }
}
