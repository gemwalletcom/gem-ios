// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum AccountDataType: Hashable, Equatable, Sendable {
    case activate
}

public enum TransferMode: Hashable, Equatable, Sendable {
    // Used for manual transfers, staking operations, and swaps
    case flexible

    // Used for preset amounts, claim rewards, scanning and specific contract calls
    case fixed
}

public enum TransferDataType: Hashable, Equatable, Sendable {
    case transfer(Asset, mode: TransferMode)
    case transferNft(NFTAsset)
    case swap(Asset, Asset, SwapData)
    case tokenApprove(Asset, ApprovalData)
    case stake(Asset, StakeType)
    case account(Asset, AccountDataType)
    case generic(asset: Asset, metadata: WalletConnectionSessionAppMetadata, extra: TransferDataExtra)
    
    public var transactionType: TransactionType {
        switch self {
        case .transfer: .transfer
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
            }
        case .account: .assetActivation
        }
    }
    
    public var chain: Chain {
        switch self {
        case .transfer(let asset, _),
            .swap(let asset, _, _),
            .stake(let asset, _),
            .account(let asset, _),
            .tokenApprove(let asset, _),
            .generic(let asset, _, _): asset.chain
        case .transferNft(let asset): asset.chain
        }
    }
    
    public var metadata: TransactionMetadata {
        switch self {
        case let .swap(fromAsset, toAsset, data): .swap(
            TransactionSwapMetadata(
                fromAsset: fromAsset.id,
                fromValue: data.quote.fromValue,
                toAsset: toAsset.id,
                toValue: data.quote.toValue,
                provider: data.quote.providerData.provider.rawValue
            )
        )
        case .transferNft(let asset): .nft(
            TransactionNFTTransferMetadata(assetId: asset.id, name: asset.name)
        )
        case .generic,
            .transfer,
            .tokenApprove,
            .stake,
            .account: .null
        }
    }
    
    public var assetIds: [AssetId] {
        switch self {
        case .transfer(let asset, _),
             .tokenApprove(let asset, _),
             .stake(let asset, _),
             .generic(let asset, _, _),
             .account(let asset, _): [asset.id]
        case let .swap(from, to, _): [from.id, to.id]
        case .transferNft: []
        }
    }

    public var outputType: TransferDataExtra.OutputType {
        return switch self {
        case .generic(_, _, let extra): extra.outputType
        default: .encodedTransaction
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
        case .transferNft, .stake, .account, .tokenApprove: true
        case .transfer, .swap, .generic: false
        }
    }

    public var canChangeValue: Bool {
        switch self {
        case let .transfer(_, mode): mode == .flexible
        case .swap: true
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake, .redelegate: true
            case .unstake, .withdraw, .rewards: false
            }
        case .transferNft, .tokenApprove, .account, .generic: false
        }
    }
}
