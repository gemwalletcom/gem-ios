// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

struct NFTAssetAssociationRecord: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static let databaseTableName = NFTAssetRecord.databaseTableName + "_associations"
    
    struct Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let collectionId = Column("collectionId")
        static let assetId = Column("assetId")
    }

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
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.id.name, .text)
                .primaryKey()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.collectionId.name, .text)
                .notNull()
                .indexed()
                .references(NFTCollectionRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .indexed()
                .references(NFTAssetRecord.databaseTableName, onDelete: .cascade)
        }
    }
}
