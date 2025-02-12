// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct TransactionStore: Sendable {
    
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func getTransactions(state: TransactionState) throws -> [Transaction] {
        try db.read { db in
            try TransactionRecord
                .filter(Columns.Transaction.state == state.rawValue)
                .fetchAll(db)
                .compactMap { $0.mapToTransaction() }
        }
    }
    
    public func getTransactionRecord(transactionId: String) throws -> TransactionRecord {
        try db.read { db in
            guard let transaction = try TransactionRecord
                .filter(Columns.Transaction.transactionId == transactionId)
                .fetchOne(db) else {
                throw AnyError("getTransaction transaction not found \(transactionId)")
            }
            return transaction
        }
    }
    
    public func getWalletIds(for transactionId: String) throws -> [String] {
        return try db.read { db in
            return try TransactionRecord
                .filter(Columns.Transaction.transactionId == transactionId)
                .fetchAll(db)
                .map { $0.walletId }
        }
    }
    
    public func addTransactions(walletId: String, transactions: [Transaction]) throws {
        try db.write { db in
            for transaction in transactions {
                let record = try transaction.record(walletId: walletId).upsertAndFetch(db, as: TransactionRecord.self)
                if let id = record.id {
                    try transaction.assetIds.forEach {
                        try TransactionAssetAssociationRecord(transactionId: id, assetId: $0.identifier).upsert(db)
                    }
                }
            }
        }
    }
    
    public func updateState(id: String, state: TransactionState) throws {
        try updateValues(id: id, values: [Columns.Transaction.state.set(to: state.rawValue)])
    }
    
    public func updateNetworkFee(transactionId: String, networkFee: String) throws {
        try updateValues(id: transactionId, values: [Columns.Transaction.fee.set(to: networkFee)])
    }
    
    public func updateBlockNumber(transactionId: String, block: Int) throws {
        try updateValues(id: transactionId, values: [Columns.Transaction.blockNumber.set(to: block)])
    }
    
    public func updateCreatedAt(transactionId: String, date: Date) throws {
        try updateValues(id: transactionId, values: [Columns.Transaction.createdAt.set(to: date)])
    }
    
    public func updateTransactionId(oldTransactionId: String, transactionId: String, hash: String) throws {
        if try isExist(transactionId: transactionId) {
            // should not exist in most cases. delete
            try deleteTransactionId(ids: [oldTransactionId])
        } else {
            return try db.write { db in
                try TransactionRecord
                    .filter(Columns.Transaction.transactionId == oldTransactionId)
                    .updateAll(db, [
                        Columns.Transaction.transactionId.set(to: transactionId),
                        Columns.Transaction.hash.set(to: hash),
                    ]
                )
            }
        }
    }
    
    public func isExist(transactionId: String) throws -> Bool {
        return try db.read { db in
            try TransactionRecord
                .filter(Columns.Transaction.transactionId == transactionId)
                .fetchCount(db) > 0
        }
    }
    
    public func deleteTransactionId(ids: [String]) throws {
        return try db.write { db in
            try TransactionRecord
                .filter(ids.contains(Columns.Transaction.transactionId))
                .deleteAll(db)
        }
    }
    
    private func updateValues(id: String, values: [ColumnAssignment]) throws {
        return try db.write { db in
            try TransactionRecord
                .filter(Columns.Transaction.transactionId == id)
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
