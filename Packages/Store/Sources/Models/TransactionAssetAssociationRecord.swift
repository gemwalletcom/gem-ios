// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

public struct TransactionAssetAssociationRecord: Codable, TableRecord, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = TransactionRecord.databaseTableName + "_assets"
    
    public var transactionId: Int
    public var assetId: String
    
    static let asset = belongsTo(AssetRecord.self)
    static let price = belongsTo(PriceRecord.self, using: ForeignKey(["assetId"], to: ["assetId"]))
}

extension TransactionAssetAssociationRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.column("transactionId", .integer)
                .notNull()
                .indexed()
                .references(TransactionRecord.databaseTableName, onDelete: .cascade)
            $0.column("assetId", .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.uniqueKey(["transactionId", "assetId"])
        }
    }
}
