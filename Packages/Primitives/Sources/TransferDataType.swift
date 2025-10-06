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
            case .open: .perpetualOpenPosition
            case .close: .perpetualClosePosition
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
            let metadata = switch type {
            case .open(let data): TransactionPerpetualMetadata(pnl: 0, price: 0, direction: data.direction, provider: nil)
            case .close(let data): TransactionPerpetualMetadata(pnl: 0, price: 0, direction: data.direction, provider: nil)
            }
            return .perpetual(metadata)
        case .generic,
            .transfer,
            .deposit,
            .withdrawal,
            .tokenApprove,
            .stake,
            .account:
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
             .perpetual(let asset, _): [asset.id]
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
        case .transferNft, .stake, .account, .tokenApprove, .perpetual: true
        case .transfer, .deposit, .withdrawal, .swap, .generic: false
        }
    }

    public var asset: Asset {
        switch self {
        case .transfer(let asset),
             .deposit(let asset),
             .withdrawal(let asset),
             .swap(let asset, _, _),
             .stake(let asset, _),
             .account(let asset, _),
             .perpetual(let asset, _),
             .tokenApprove(let asset, _),
             .generic(let asset, _, _):
            return asset
        case .transferNft:
            fatalError("NFT asset not supported")
        }
    }
}
