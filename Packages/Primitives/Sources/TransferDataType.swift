// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapQuote
import enum Gemstone.SwapProvider
import struct Gemstone.SwapQuoteData

public enum AccountDataType: Hashable, Equatable, Sendable {
    case activate
}

public enum TransferDataType: Hashable, Equatable, Sendable {
    case transfer(Asset)
    case transferNft(NFTAsset)
    case swap(Asset, Asset, SwapQuote, SwapQuoteData)
    case stake(Asset, StakeType)
    case account(Asset, AccountDataType)
    case generic(asset: Asset, metadata: WalletConnectionSessionAppMetadata, extra: TransferDataExtra)
    
    public var data: Data? {
        switch self {
        case .transfer, .transferNft:
            return .none
        case .swap(_, _, _, let data):
            return Data(fromHex: data.data)
        case .stake, .account:
            // singer needs to setup correctly
            return .none
        case .generic(_, _, let extra):
            return extra.data
        }
    }

    public var stakeChain: StakeChain? {
        guard case let .stake(asset, _) = self else {
            return nil
        }
        return asset.chain.stakeChain
    }

    public var stakeType: StakeType? {
        guard case let .stake(_, type) = self else {
            return nil
        }
        return type
    }

    public var transactionType: TransactionType {
        switch self {
        case .transfer: .transfer
        case .generic: .smartContractCall
        case .transferNft: .transferNFT
        case .swap: .swap
        case .stake(_, let type):
            switch type {
            case .stake: .stakeDelegate
            case .unstake: .stakeUndelegate
            case .redelegate: .stakeRedelegate
            case .rewards: .stakeRewards
            case .withdraw: .stakeWithdraw
            }
        case .account(_, _): .assetActivation
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
            .stake,
            .account,
            .transferNft:
            return .null
        }
    }
    
    public var assetIds: [AssetId] {
        switch self {
        case .transfer(let asset):
            [asset.id]
        case .swap(let from, let to, _, _):
            [from.id, to.id]
        case .stake(let asset, _):
            [asset.id]
        case .generic(let asset, _, _):
            [asset.id]
        case .account(let asset, _):
            [asset.id]
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
