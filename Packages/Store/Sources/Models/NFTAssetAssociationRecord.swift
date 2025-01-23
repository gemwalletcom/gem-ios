// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

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
