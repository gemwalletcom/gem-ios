// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum TransferDataType: Hashable, Equatable, Sendable {
    case transfer(Asset)
    case deposit(Asset)
    case withdrawal(Asset)
    case transferNft(NFTAsset)
    case swap(Asset, Asset, SwapData)
    case tokenApprove(Asset, ApprovalData)
    case stake(Asset, StakeType)
    case account(Asset, AccountDataType)
    case perpetual(Asset, PerpetualType)
    case yield(Asset, YieldAction, YieldData)
    case generic(asset: Asset, metadata: WalletConnectionSessionAppMetadata, extra: TransferDataExtra)

    public var transactionType: TransactionType {
        switch self {
        case .transfer: .transfer
        case .deposit: .transfer
        case .withdrawal: .transfer
        case .generic: .smartContractCall
        case .transferNft: .transferNFT
        case .tokenApprove: .tokenApproval
        case .swap: .swap
        case .stake(_, let type):
            switch type {
            case .stake: .stakeDelegate
            case .unstake: .stakeUndelegate
            case .redelegate: .stakeRedelegate
            case .rewards: .stakeRewards
            case .withdraw: .stakeWithdraw
            case .freeze(let data):
                switch data.freezeType {
                case .freeze: .stakeFreeze
                case .unfreeze: .stakeUnfreeze
                }
            }
        case .account: .assetActivation
        case .perpetual(_, let type):
            switch type {
            case .open, .increase: .perpetualOpenPosition
            case .close, .reduce: .perpetualClosePosition
            case .modify: .perpetualModifyPosition
            }
        case .yield(_, let action, _):
            switch action {
            case .deposit: .stakeDelegate
            case .withdraw: .stakeUndelegate
            }
        }
    }

    public var chain: Chain {
        switch self {
        case .transfer(let asset),
             .deposit(let asset),
             .withdrawal(let asset),
             .swap(let asset, _, _),
             .stake(let asset, _),
             .account(let asset, _),
             .perpetual(let asset, _),
             .yield(let asset, _, _),
             .tokenApprove(let asset, _),
             .generic(let asset, _, _): asset.chain
        case .transferNft(let asset): asset.chain
        }
    }

    public var metadata: TransactionMetadata {
        switch self {
        case .swap(let fromAsset, let toAsset, let data):
            return .swap(
                TransactionSwapMetadata(
                    fromAsset: fromAsset.id,
                    fromValue: data.quote.fromValue,
                    toAsset: toAsset.id,
                    toValue: data.quote.toValue,
                    provider: data.quote.providerData.provider.rawValue
                )
            )
        case .transferNft(let asset):
            return .nft(
                TransactionNFTTransferMetadata(assetId: asset.id, name: asset.name)
            )
        case .perpetual(_, let type):
            if let direction = type.data?.direction {
                return .perpetual(TransactionPerpetualMetadata(pnl: 0, price: 0, direction: direction, provider: nil))
            }
            return .null
        case .stake(_, let type):
            switch type {
            case .freeze(let data):
                return .generic(from: TransactionResourceTypeMetadata(resourceType: data.resource))
            case .stake, .unstake, .redelegate, .rewards, .withdraw:
                return .null
            }
        case .generic,
            .transfer,
            .deposit,
            .withdrawal,
            .tokenApprove,
            .account,
            .yield:
            return .null
        }
    }

    public var assetIds: [AssetId] {
        switch self {
        case .transfer(let asset),
             .deposit(let asset),
             .withdrawal(let asset),
             .tokenApprove(let asset, _),
             .stake(let asset, _),
             .generic(let asset, _, _),
             .account(let asset, _),
             .perpetual(let asset, _),
             .yield(let asset, _, _): [asset.id]
        case .swap(let from, let to, _): [from.id, to.id]
        case .transferNft: []
        }
    }

    public var outputType: TransferDataOutputType {
        return switch self {
        case .generic(_, _, let extra): extra.outputType
        default: .encodedTransaction
        }
    }
    
    public var outputAction: TransferDataOutputAction {
        return switch self {
        case .generic(_, _, let extra): extra.outputAction
        default: .send
        }
    }

    public func swap() throws -> (Asset, Asset, data: SwapData) {
        guard case .swap(let fromAsset, let toAsset, let data) = self else {
            throw AnyError("SwapQuoteData missed")
        }
        return (fromAsset, toAsset, data)
    }
    
    public var shouldIgnoreValueCheck: Bool {
        switch self {
        case .transferNft, .stake, .account, .tokenApprove, .perpetual, .yield: true
        case .transfer, .deposit, .withdrawal, .swap, .generic: false
        }
    }

    public var recentActivityData: RecentActivityData? {
        switch self {
        case .transfer(let asset): RecentActivityData(type: .transfer, assetId: asset.id, toAssetId: nil)
        case .swap(let from, let to, _): RecentActivityData(type: .swap, assetId: from.id, toAssetId: to.id)
        default: nil
        }
    }
}
