// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import Primitives // TODO: - integrate Sendable for AssetId & TransactionType & TransactionState

public enum TransactionsRequestType: Equatable {
    case all
    case pending
    case asset(assetId: AssetId)
    case assetsTransactionType(assetIds: [AssetId], type: TransactionType, states: [TransactionState])
    case transaction(id: String)
}

extension TransactionsRequestType: Identifiable {
    public var id: String {
        switch self {
        case .all: return "all"
        case .pending: return "pending"
        case .transaction(let id): return id
        case .asset(let asset): return asset.identifier
        case .assetsTransactionType(let assetIds, let type, _):
            return assetIds.map { $0.identifier }.joined() + type.rawValue
        }
    }
}

extension TransactionsRequestType: Sendable {}
