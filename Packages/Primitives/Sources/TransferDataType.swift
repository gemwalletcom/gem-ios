// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.ApprovalData
import struct Gemstone.SwapQuote
import struct Gemstone.SwapQuoteData

public enum AccountDataType: Hashable, Equatable, Sendable {
    case activate
}

public enum TransferDataType: Hashable, Equatable, Sendable {
    case transfer(Asset)
    case transferNft(NFTAsset)
    case swap(Asset, Asset, SwapQuote, SwapQuoteData)
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
        case .transfer(let asset),
             .swap(let asset, _, _, _),
             .stake(let asset, _),
             .account(let asset, _),
             .tokenApprove(let asset, _),
             .generic(let asset, _, _): asset.chain
        case .transferNft(let asset): asset.chain
        }
    }

    public var metadata: TransactionMetadata {
        switch self {
        case .swap(let fromAsset, let toAsset, let quote, _):
            return .swap(
                TransactionSwapMetadata(
                    fromAsset: fromAsset.id,
                    fromValue: quote.fromValue,
                    toAsset: toAsset.id,
                    toValue: quote.toValue
                )
            )
        case .generic,
             .transfer,
             .tokenApprove,
             .stake,
             .account,
             .transferNft:
            return .null
        }
    }

    public var assetIds: [AssetId] {
        switch self {
        case .transfer(let asset),
             .tokenApprove(let asset, _),
             .stake(let asset, _),
             .generic(let asset, _, _),
             .account(let asset, _):
            [asset.id]
        case .swap(let from, let to, _, _):
            [from.id, to.id]
        case .transferNft: []
        }
    }

    public var outputType: TransferDataExtra.OutputType {
        return switch self {
        case .generic(_, _, let extra): extra.outputType
        default: .encodedTransaction
        }
    }
}
