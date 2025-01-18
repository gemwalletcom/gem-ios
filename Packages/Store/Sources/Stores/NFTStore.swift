import Foundation
import GRDB
import Primitives

public struct NFTStore: Sendable {
    private let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    // MARK: - Public methods

    public func saveNFTData(_ data: [NFTData], for walletId: String) throws {
        try removeStaleNFTCollections(new: data, walletId: walletId)

        try db.write { db in
            for nftData in data {
                let collection = nftData.collection
                
                let nftCollectionRecord = collection.record(for: walletId)
                try nftCollectionRecord.insert(db, onConflict: .replace)
                
                let collectionImageRecord = collection.image.collectionRecord(for: collection.id)
                try collectionImageRecord.insert(db, onConflict: .replace)
                
                for asset in nftData.assets {
                    let assetRecord = asset.record()
                    try assetRecord.insert(db, onConflict: .replace)
                    
                    let imageRecord = asset.image.nftRecord(for: asset.id)
                    try imageRecord.insert(db, onConflict: .replace)
                    
                    for attribute in asset.attributes {
                        let attributeRecord = attribute.record(for: asset.id)
                        try attributeRecord.insert(db, onConflict: .replace)
                    }
                }
            }
        }
    }
    
    public func getNFTResults(for walletId: String) throws -> [NFTData] {
        try db.read { db in
            try NFTCollectionRecord
                .filter(Columns.NFT.walletId == walletId)
                .including(
                    all: NFTCollectionRecord.assets
                        .including(required: NFTAssetRecord.image)
                        .including(all: NFTAssetRecord.attributes)
                )
                .including(required: NFTCollectionRecord.image)
                .asRequest(of: NFTCollectionRecordInfo.self)
                .fetchAll(db)
                .map { $0.mapToNFTData() }
        }
    }
    
    // MARK: - Private methods
    
    private func removeStaleNFTCollections(new data: [NFTData], walletId: String) throws {
        let existing = try getNFTResults(for: walletId)
        let existingCollectionIds = existing.map { $0.collection.id }.asSet()
        
        let newCollectionIds = data.map { $0.collection.id }.asSet()
        
        let idsToDelete = existingCollectionIds.subtracting(newCollectionIds).asArray()
        return try db.write { db in
            try NFTCollectionRecord
                .filter(idsToDelete.contains(Columns.NFT.id) && Columns.NFT.walletId == walletId)
                .deleteAll(db)
        }
    }
}
