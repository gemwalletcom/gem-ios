// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct TransactionStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func getTransactionWallets(
        state: TransactionState
    ) throws -> [TransactionWallet] {
        try db.read { db in
            try TransactionRecord
                .including(required: TransactionRecord.wallet)
                .filter(TransactionRecord.Columns.state == state.rawValue)
                .asRequest(of: WalletTransactionInfo.self)
                .fetchAll(db)
                .map(\.transactionWallet)
        }
    }

    public func getTransactions(state: TransactionState) throws -> [Transaction] {
        try db.read { db in
            try TransactionRecord
                .filter(TransactionRecord.Columns.state == state.rawValue)
                .fetchAll(db)
                .compactMap { $0.mapToTransaction() }
        }
    }

    public func getTransactionRecord(transactionId: String) throws -> TransactionRecord {
        try db.read { db in
            guard let transaction = try TransactionRecord
                .filter(TransactionRecord.Columns.transactionId == transactionId)
                .fetchOne(db) else {
                throw AnyError("getTransaction transaction not found \(transactionId)")
            }
            return transaction
        }
    }

    public func getWalletIds(for transactionId: String) throws -> [String] {
        return try db.read { db in
            return try TransactionRecord
                .filter(TransactionRecord.Columns.transactionId == transactionId)
                .fetchAll(db)
                .map { $0.walletId }
        }
    }

    public func getTransactionAssetAssociations(for transactionId: String) throws -> [TransactionAssetAssociationRecord] {
        try db.read { db in
            try TransactionAssetAssociationRecord
                .joining(required: TransactionAssetAssociationRecord.transaction)
                .filter(TransactionRecord.Columns.transactionId == transactionId)
                .fetchAll(db)
        }
    }
    
    public func getTransaction(walletId: WalletId, transactionId: String) throws -> TransactionExtended {
        try db.read { db in
            try TransactionRequest(walletId: walletId, transactionId: transactionId).fetch(db)
        }
    }

    public func addTransactions(walletId: WalletId, transactions: [Transaction]) throws {
        if transactions.isEmpty {
            return
        }
        try db.write { db in
            for transaction in transactions {
                let record = try transaction.record(walletId: walletId.id).upsertAndFetch(db, as: TransactionRecord.self)
                if let id = record.id {
                    try TransactionAssetAssociationRecord
                        .filter(TransactionAssetAssociationRecord.Columns.transactionId == id)
                        .deleteAll(db)
                    
                    try transaction.assetIds.forEach {
                        try TransactionAssetAssociationRecord(transactionId: id, assetId: $0).upsert(db)
                    }
                }
            }
        }
    }

    public func updateState(id: String, state: TransactionState) throws {
        try updateValues(id: id, values: [TransactionRecord.Columns.state.set(to: state.rawValue)])
    }

    public func updateNetworkFee(transactionId: String, networkFee: String) throws {
        try updateValues(id: transactionId, values: [TransactionRecord.Columns.fee.set(to: networkFee)])
    }

    public func updateBlockNumber(transactionId: String, block: Int) throws {
        try updateValues(id: transactionId, values: [TransactionRecord.Columns.blockNumber.set(to: block)])
    }

    public func updateCreatedAt(transactionId: String, date: Date) throws {
        try updateValues(id: transactionId, values: [TransactionRecord.Columns.createdAt.set(to: date)])
    }

    public func updateMetadata(transactionId: String, metadata: TransactionMetadata) throws {
        let string = try JSONEncoder().encode(metadata).encodeString()
        try updateValues(
            id: transactionId,
            values: [TransactionRecord.Columns.metadata.set(to: string)]
        )
    }

    public func updateTransactionId(oldTransactionId: String, transactionId: String, hash: String) throws {
        if try isExist(transactionId: transactionId) {
            // should not exist in most cases. delete
            try deleteTransactionId(ids: [oldTransactionId])
        } else {
            return try db.write { db in
                try TransactionRecord
                    .filter(TransactionRecord.Columns.transactionId == oldTransactionId)
                    .updateAll(db, [
                        TransactionRecord.Columns.transactionId.set(to: transactionId),
                        TransactionRecord.Columns.hash.set(to: hash),
                    ])
            }
        }
    }

    public func isExist(transactionId: String) throws -> Bool {
        return try db.read { db in
            try TransactionRecord
                .filter(TransactionRecord.Columns.transactionId == transactionId)
                .fetchCount(db) > 0
        }
    }

    public func deleteTransactionId(ids: [String]) throws {
        return try db.write { db in
            try TransactionRecord
                .filter(ids.contains(TransactionRecord.Columns.transactionId))
                .deleteAll(db)
        }
    }

    private func updateValues(id: String, values: [ColumnAssignment]) throws {
        return try db.write { db in
            try TransactionRecord
                .filter(TransactionRecord.Columns.transactionId == id)
                .updateAll(db, values)
        }
    }

    @discardableResult
    public func clear() throws -> Int {
        try db.write { db in
            try TransactionRecord
                .deleteAll(db)
        }
    }
}
