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
            .perpetualClosePosition,
            .perpetualModifyPosition,
            .stakeFreeze,
            .stakeUnfreeze:
            return [assetId]
        case .swap:
            guard case .swap(let metadata) = metadata else {
                return []
            }
            return [metadata.fromAsset, metadata.toAsset]
        }
    }

    public var swapProvider: String? {
        guard case let .swap(metadata) = self.metadata else {
            return nil
        }
        return metadata.provider
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
