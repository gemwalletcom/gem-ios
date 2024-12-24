// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Transaction {
    
    public static func id(chain: String, hash: String) -> String {
        return String(format: "%@_%@", chain, hash)
    }
    
    public var valueBigInt: BigInt {
        return BigInt(value) ?? .zero
    }
    
    public var feeBigInt: BigInt {
        return BigInt(fee) ?? .zero
    }
    
    public var assetIds: [AssetId] {
        switch type {
        case .transfer,
            .tokenApproval,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw,
            .assetActivation:
            return [assetId]
        case .swap:
            switch metadata {
            case .null, .none: return []
            case .swap(let value):
                return [value.fromAsset, value.toAsset]
            }
        }
    }
}

extension Transaction: Equatable {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id &&
        lhs.state == rhs.state &&
        lhs.createdAt == rhs.createdAt
    }
}

extension Transaction: Identifiable { }
