// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct TransactionRecord: Codable, TableRecord, FetchableRecord, PersistableRecord  {
    public static let databaseTableName: String = "transactions_v23"
    
    public enum Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let transactionId = Column("transactionId")
        static let hash = Column("hash")
        static let from = Column("from")
        static let to = Column("to")
        static let contract = Column("contract")
        static let type = Column("type")
        static let chain = Column("chain")
        static let assetId = Column("assetId")
        static let blockNumber = Column("blockNumber")
        static let value = Column("value")
        static let fee = Column("fee")
        static let feeAssetId = Column("feeAssetId")
        static let sequence = Column("sequence")
        static let date = Column("date")
        static let state = Column("state")
        static let memo = Column("memo")
        static let metadata = Column("metadata")
        static let direction = Column("direction")
        static let createdAt = Column("createdAt")
        static let updatedAt = Column("updatedAt")
    }

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
    public var metadata: AnyCodableValue?
    public var createdAt: Date
    public var updatedAt: Date

    static let wallet = belongsTo(WalletRecord.self, key: "wallet", using: ForeignKey(["walletId"], to: ["id"]))

    // delete asset / price properties as they could be fetched from assets / prics
    static let asset = belongsTo(AssetRecord.self, key: "asset", using: ForeignKey(["assetId"], to: ["id"]))
    static let feeAsset = belongsTo(AssetRecord.self, key: "feeAsset", using: ForeignKey(["feeAssetId"], to: ["id"]))
    
    static let price = belongsTo(PriceRecord.self, key: "price", using: ForeignKey(["assetId"], to: ["assetId"]))
    static let feePrice = belongsTo(PriceRecord.self, key: "feePrice", using: ForeignKey(["feeAssetId"], to: ["assetId"]))
    
    static let fromAddress = belongsTo(AddressRecord.self, key: "fromAddress", using: ForeignKey(["chain", "from"], to: ["chain", "address"]))
    static let toAddress = belongsTo(AddressRecord.self, key: "toAddress", using: ForeignKey(["chain", "to"], to: ["chain", "address"]))
    
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
            $0.autoIncrementedPrimaryKey(Columns.id.name)
                .indexed()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.transactionId.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.hash.name, .text)
                .indexed()
                .notNull()
            $0.column(Columns.from.name, .text)
                .notNull()
            $0.column(Columns.to.name, .text)
                .notNull()
            $0.column(Columns.contract.name, .text)
            $0.column(Columns.type.name, .text)
                .notNull()
            $0.column(Columns.chain.name, .text)
                .notNull()
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.blockNumber.name, .numeric)
                .notNull()
            $0.column(Columns.value.name, .text)
                .notNull()
            $0.column(Columns.fee.name, .text)
                .notNull()
            $0.column(Columns.feeAssetId.name, .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.sequence.name, .numeric)
                .notNull()
            $0.column(Columns.date.name, .date)
                .indexed()
                .notNull()
            $0.column(Columns.state.name, .text)
                .notNull()
            $0.column(Columns.memo.name, .text)
            $0.column(Columns.metadata.name, .jsonText)
            $0.column(Columns.direction.name, .text)
                .notNull()
            $0.column(Columns.createdAt.name, .date)
                .notNull()
            $0.column(Columns.updatedAt.name, .date)
                .notNull()
            $0.uniqueKey([
                Columns.walletId.name,
                Columns.transactionId.name
            ])
        }
    }
}

extension TransactionRecord {
    func mapToTransaction() -> Transaction {
        return Transaction(
            id: TransactionId(chain: assetId.chain, hash: hash),
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
    func record(walletId: String) throws -> TransactionRecord {
        return TransactionRecord(
            walletId: walletId,
            transactionId: id.identifier,
            hash: id.hash,
            type: type,
            from: from,
            to: to,
            contract: contract,
            chain: assetId.chain,
            assetId: assetId,
            blockNumber: Int(blockNumber ?? "0") ?? 0,
            value: value,
            fee: fee,
            feeAssetId: feeAssetId,
            sequence: Int(sequence ?? "0") ?? 0,
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
