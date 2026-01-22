// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import BigInt
import Components
import Localization
import Formatters
import Style
import GemstonePrimitives

public enum InfoSheetType: Identifiable, Sendable, Equatable {
    case networkFee(Chain)
    case insufficientBalance(Asset, image: AssetImage)
    case insufficientNetworkFee(Asset, image: AssetImage, required: BigInt?, action: InfoSheetAction)
    case transactionState(imageURL: URL?, placeholder: Image?, state: TransactionState)
    case watchWallet
    case stakeLockTime(Image?)
    case stakeApr(Image?)
    case dustThreshold(Chain, image: AssetImage)
    // swaps
    case priceImpact
    case slippage
    case noQuote
    // asset
    case assetStatus(AssetScoreType)
    case accountMinimalBalance(Asset, required: BigInt)
    // stake
    case stakeMinimumAmount(Asset, required: BigInt, action: InfoSheetAction)
    case stakingReservedFees(image: AssetImage)
    case pendingUnconfirmedBalance
    // perpetuals
    case fundingRate
    case fundingPayments
    case liquidationPrice
    case openInterest
    case autoclose
    // scan transaction
    case maliciousTransaction
    case memoRequired(symbol: String)
    // market
    case fullyDilutedValuation
    case circulatingSupply
    case totalSupply
    case maxSupply

    public var id: String {
        switch self {
        case .networkFee: "networkFees"
        case .insufficientNetworkFee: "insufficientNetworkFee"
        case let .insufficientBalance(asset, _): "insufficientBalance_\(asset.id.identifier)"
        case let .transactionState(_, _, state): state.id
        case .watchWallet: "watchWallet"
        case .stakeLockTime: "stakeLockTime"
        case .stakeApr: "stakeApr"
        case .priceImpact: "priceImpact"
        case .slippage: "slippage"
        case let .assetStatus(status): "assetStatus_\(status.rawValue)"
        case let .accountMinimalBalance(asset, amount): "accountMinimalBalance_\(asset.id.identifier)\(amount)"
        case let .stakeMinimumAmount(asset, amount, _): "stakeMinimumAmount_\(asset.id.identifier)\(amount)"
        case .stakingReservedFees: "stakingReservedFees"
        case .pendingUnconfirmedBalance: "pendingUnconfirmedBalance"
        case .noQuote: "noQuote"
        case .fundingRate: "fundingRate"
        case .fundingPayments: "fundingPayments"
        case .liquidationPrice: "liquidationPrice"
        case .openInterest: "openInterest"
        case .autoclose: "autoClose"
        case .maliciousTransaction: "maliciousTransaction"
        case let .memoRequired(symbol): "memoRequired_\(symbol)"
        case let .dustThreshold(chain, _): "dustThreshold_\(chain.rawValue)"
        case .fullyDilutedValuation: "fullyDilutedValuation"
        case .circulatingSupply: "circulatingSupply"
        case .totalSupply: "totalSupply"
        case .maxSupply: "maxSupply"
        }
    }
    
    public static func == (lhs: InfoSheetType, rhs: InfoSheetType) -> Bool {
        lhs.id == rhs.id
    }
}
