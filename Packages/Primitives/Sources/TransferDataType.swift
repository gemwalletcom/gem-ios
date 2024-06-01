// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public enum StakeType: Hashable, Equatable {
    case stake(validator: DelegationValidator)
    case unstake(delegation: Delegation)
    case redelegate(delegation: Delegation, toValidator: DelegationValidator)
    case rewards(validators: [DelegationValidator])
    case withdraw(delegation: Delegation)
}

public enum TransferDataType: Hashable, Equatable {
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
            case .swap(let data):
                return data.hexData
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
            case .swap(let data):
                return .swap(
                    TransactionSwapMetadata(
                        fromAsset: fromAsset.id,
                        fromValue: data.quote.fromAmount,
                        toAsset: toAsset.id,
                        toValue: data.quote.toAmount
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

public struct TransferDataExtra: Equatable {
    public let gasLimit: BigInt?
    public let gasPrice: GasPriceType?
    public let data: Data?
    
    public init(
        gasLimit: BigInt? = .none,
        gasPrice: GasPriceType? = .none,
        data: Data? = .none
    ) {
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.data = data
    }
}
extension TransferDataExtra: Hashable {}

public enum SwapAction {
    case swap(SwapData)
    case approval(spender: String, allowance: BigInt)
}

extension SwapAction: Hashable {}

public struct SwapApproval: Equatable {
    public let allowance: BigInt
    public let spender: String
}
extension SwapApproval: Hashable {}

public struct SwapData: Equatable {
    public let quote: SwapQuote
    
    public init(
        quote: SwapQuote
    ) {
        self.quote = quote
    }
}

extension SwapData {
    public var hexData: Data? {
        guard let value = quote.data?.data else {
            return .none
        }
        return Data(fromHex: value)
    }
}

extension SwapData: Hashable {}
