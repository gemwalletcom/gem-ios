// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

public struct TransactionRecord: Codable, TableRecord, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "transactions_v23"

    public var id: Int? = .none
    public var walletId: String
    public var transactionId: String
    public var hash: String
    public var type: TransactionType
    public var from: String
    public var to: String
    public var contract: String?
    public var chain: Chain
    public var assetId: AssetId
    public var blockNumber: Int
    public var value: String
    public var fee: String
    public var feeAssetId: AssetId
    public var sequence: Int
    public var date: Date
    public var state: String
    public var memo: String?
    public var direction: TransactionDirection
    public var metadata: TransactionMetadata?
    public var createdAt: Date
    public var updatedAt: Date
    
    // delete asset / price properties as they could be fetched from assets / prics
    static let asset = belongsTo(AssetRecord.self, key: "asset", using: ForeignKey(["assetId"], to: ["id"]))
    static let feeAsset = belongsTo(AssetRecord.self, key: "feeAsset", using: ForeignKey(["feeAssetId"], to: ["id"]))
    
    static let price = belongsTo(PriceRecord.self, key: "price", using: ForeignKey(["assetId"], to: ["assetId"]))
    static let feePrice = belongsTo(PriceRecord.self, key: "feePrice", using: ForeignKey(["feeAssetId"], to: ["assetId"]))
    
    static let assetsAssociation = hasMany(TransactionAssetAssociationRecord.self)
    static let pricesAssociation = hasMany(TransactionAssetAssociationRecord.self)
    static let assets = hasMany(AssetRecord.self, through: assetsAssociation, using: TransactionAssetAssociationRecord.asset)
    static let prices = hasMany(
        PriceRecord.self,
        through: pricesAssociation,
        using: TransactionAssetAssociationRecord.price
    )
}

extension TransactionRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.autoIncrementedPrimaryKey("id")
                .indexed()
            $0.column("walletId", .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column("transactionId", .text)
                .notNull()
                .indexed()
            $0.column("hash", .text)
                .indexed()
                .notNull()
            $0.column("from", .text)
                .notNull()
            $0.column("to", .text)
                .notNull()
            $0.column("contract", .text)
            $0.column("type", .text)
                .notNull()
            $0.column("chain", .text)
                .notNull()
            $0.column("assetId", .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column("blockNumber", .numeric)
                .notNull()
            $0.column("value", .text)
                .notNull()
            $0.column("fee", .text)
                .notNull()
            $0.column("feeAssetId", .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column("sequence", .numeric)
                .notNull()
            $0.column("date", .date)
                .indexed()
                .notNull()
            $0.column("state", .text)
                .notNull()
            $0.column("memo", .text)
            $0.column("metadata", .jsonText)
            $0.column("direction", .text)
                .notNull()
            $0.column("createdAt", .date)
                .notNull()
            $0.column("updatedAt", .date)
                .notNull()
            $0.uniqueKey(["walletId", "transactionId"])
        }
    }
}

extension TransactionRecord {
    func mapToTransaction() -> Transaction {
        return Transaction(
            id: Transaction.id(chain: assetId.chain, hash: hash),
            hash: hash,
            assetId: assetId,
            from: from,
            to: to,
            contract: contract,
            type: type,
            state: TransactionState(rawValue: state) ?? .pending,
            blockNumber: blockNumber.asString,
            sequence: sequence.asString,
            fee: fee,
            feeAssetId: feeAssetId,
            value: value,
            memo: memo,
            direction: direction,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: metadata,
            createdAt: createdAt
        )
    }
}

extension Transaction {
    func record(walletId: String) -> TransactionRecord {
        return TransactionRecord(
            walletId: walletId,
            transactionId: Transaction.id(chain: assetId.chain, hash: hash),
            hash: hash,
            type: type,
            from: from,
            to: to,
            contract: contract,
            chain: assetId.chain,
            assetId: assetId,
            blockNumber: Int(blockNumber) ?? 0,
            value: value,
            fee: fee,
            feeAssetId: feeAssetId,
            sequence: Int(sequence) ?? 0,
            date: createdAt,
            state: state.rawValue,
            memo: memo,
            direction: direction,
            metadata: metadata,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}
