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
            .smartContractCall:
            return [assetId]
        case .swap:
            switch metadata {
            case .null, .none: return []
            case .swap(let value):
                return [value.fromAsset, value.toAsset]
            }
        }
    }

    public func withState(_ newState: TransactionState) -> Transaction {
          Transaction(
              id: id,
              hash: hash,
              assetId: assetId,
              from: from,
              to: to,
              contract: contract,
              type: type,
              state: newState,
              blockNumber: blockNumber,
              sequence: sequence,
              fee: fee,
              feeAssetId: feeAssetId,
              value: value,
              memo: memo,
              direction: direction,
              utxoInputs: utxoInputs,
              utxoOutputs: utxoOutputs,
              metadata: metadata,
              createdAt: createdAt
          )
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
