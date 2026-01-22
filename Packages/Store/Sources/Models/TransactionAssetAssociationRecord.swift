// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct TransactionAssetAssociationRecord: Codable, TableRecord, FetchableRecord, PersistableRecord  {
    public static let databaseTableName: String = TransactionRecord.databaseTableName + "_assets"
    
    public enum Columns {
        static let transactionId = Column("transactionId")
        static let assetId = Column("assetId")
    }
    
    public var transactionId: Int
    public var assetId: AssetId
    
    static let transaction = belongsTo(TransactionRecord.self, using: ForeignKey(["transactionId"], to: ["id"]))
    static let asset = belongsTo(AssetRecord.self)
    static let price = belongsTo(PriceRecord.self, using: ForeignKey(["assetId"], to: ["assetId"]))
}

extension TransactionAssetAssociationRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.column(Columns.transactionId.name, .integer)
                .notNull()
                .indexed()
                .references(TransactionRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.uniqueKey([
                Columns.transactionId.name,
                Columns.assetId.name
            ])
        }
    }
}
