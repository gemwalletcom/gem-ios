// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Transaction {
    
    public static func id(chain: Chain, hash: String) -> String {
        return String(format: "%@_%@", chain.rawValue, hash)
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
            .assetActivation,
            .transferNFT,
            .smartContractCall,
            .perpetualOpenPosition,
            .perpetualClosePosition:
            return [assetId]
        case .swap:
            switch metadata {
            case .null, .nft, .none: return []
            case .swap(let value):
                return [value.fromAsset, value.toAsset]
            }
        }
    }
}

extension Transaction: Identifiable { }

extension TransactionMetadata: Equatable {
    public static func == (lhs: TransactionMetadata, rhs: TransactionMetadata) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):
            return true
        case (.swap(let lhsSwap), .swap(let rhsSwap)):
            return lhsSwap.fromAsset == rhsSwap.fromAsset &&
            lhsSwap.toAsset == rhsSwap.toAsset &&
            lhsSwap.toValue == rhsSwap.toValue &&
            lhsSwap.fromValue == rhsSwap.fromValue
        default:
            return false
        }
    }
}
