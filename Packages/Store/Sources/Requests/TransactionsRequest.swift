// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct TransactionsRequest: Queryable {
    public static var defaultValue: [TransactionExtended] { [] }
    
    let walletId: String
    let type: TransactionsRequestType
    let limit: Int
    
    public init(
        walletId: String,
        type: TransactionsRequestType,
        limit: Int = 50
    ) {
        self.walletId = walletId
        self.type = type
        self.limit = limit
    }
    
    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[TransactionExtended], Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    private func fetch(_ db: Database) throws -> [TransactionExtended] {
        let states = states(type: type)
        let types = types(type: type)
        var request = TransactionRecord
            .filter(Columns.Transaction.walletId == walletId)
            .filter(states.contains(Columns.Transaction.state))
            .filter(types.contains(Columns.Transaction.type))
            .including(required: TransactionRecord.asset)
            .including(required: TransactionRecord.feeAsset)
            .including(optional: TransactionRecord.price)
            .including(optional: TransactionRecord.feePrice)
            .including(all: TransactionRecord.assets)
            .order(Columns.Transaction.date.desc)
            .distinct()
            .limit(limit)
    
        switch type {
        case .asset(let assetId):
            request = request.joining(required: TransactionRecord.assetsAssociation.filter(Columns.TransactionAssetAssociation.assetId == assetId.identifier))
        case .assetsTransactionType(let assetIds, _, _):
            request = request.joining(required: TransactionRecord.assetsAssociation.filter(assetIds.map { $0.identifier }.contains(Columns.TransactionAssetAssociation.assetId)))
        case .transaction(let id):
            request = request.filter(Columns.Transaction.transactionId == id)
        case .all, .pending:
            break
        }
        
        return try request.asRequest(of: TransactionInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToTransactionExtended() }
    }
    
    private func states(type: TransactionsRequestType) -> [String] {
        switch type {
        case .pending:
            return [TransactionState.pending.rawValue]
        case .all, .asset, .transaction:
            return TransactionState.allCases.map { $0.rawValue }
        case .assetsTransactionType(_, _, let states):
            return states.map { $0.rawValue }
        }
    }
    
    private func types(type: TransactionsRequestType) -> [String] {
        switch type {
        case .assetsTransactionType(_, let type, _):
            return [type.rawValue]
        case .pending, .all, .asset, .transaction:
            return TransactionType.allCases.map { $0.rawValue }
        }
    }
}
