// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum TransferDataType: Hashable, Equatable, Sendable {
    case transfer(Asset)
    case swap(Asset, Asset, SwapAction)
    case stake(Asset, StakeType)
    case generic(asset: Asset, metadata: WalletConnectionSessionAppMetadata, extra: TransferDataExtra)
    
    public var data: Data? {
        switch self {
        case .transfer:
            return .none
        case .swap(_, _, let extra):
            switch extra {
            case .swap(_, let data):
                return Data(fromHex: data.data)
            case .approval:
                // none here, data calculated via signer
                return .none
            }
        case .stake:
            // singer needs to setup correctly
            return .none
        case .generic(_, _, let extra):
            return extra.data
        }
    }

    public var stakeChain: StakeChain? {
        switch self {
        case .transfer, .generic, .swap:
            return .none
        case .stake(let asset, _):
            return asset.chain.stakeChain
        }
    }

    public var stakeType: StakeType? {
        switch self {
        case .transfer, .generic, .swap:
            return .none
        case .stake(_, let type):
            return type
        }
    }

    public var transactionType: TransactionType {
        switch self {
        case .transfer, .generic: .transfer
        case .swap(_, _, let type):
            switch type {
            case .approval: .tokenApproval
            case .swap: .swap
            }
        case .stake(_, let type):
            switch type {
            case .stake: .stakeDelegate
            case .unstake: .stakeUndelegate
            case .redelegate: .stakeRedelegate
            case .rewards: .stakeRewards
            case .withdraw: .stakeWithdraw
            }
        }
    }
    
    public var metadata: TransactionMetadata {
        switch self {
        case .swap(let fromAsset, let toAsset, let type):
            switch type {
            case .swap(let quote, _):
                return .swap(
                    TransactionSwapMetadata(
                        fromAsset: fromAsset.id,
                        fromValue: quote.fromValue,
                        toAsset: toAsset.id,
                        toValue: quote.toValue
                    )
                )
            case .approval:
                return .null
            }
        case .generic:
            return .null
        case .transfer:
            return .null
        case .stake:
            return .null
        }
    }
    
    public var assetIds: [AssetId] {
        switch self {
        case .transfer(let asset):
            [asset.id]
        case .swap(let from, let to, _):
            [from.id, to.id]
        case .stake(let asset, _):
            [asset.id]
        case .generic(let asset, _, _):
            [asset.id]
        }
    }
}
