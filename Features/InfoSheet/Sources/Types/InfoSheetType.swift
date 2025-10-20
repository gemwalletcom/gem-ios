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
    // perpetuals
    case fundingRate
    case fundingPayments
    case liquidationPrice
    case openInterest


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
        case .noQuote: "noQuote"
        case .fundingRate: "fundingRate"
        case .fundingPayments: "fundingPayments"
        case .liquidationPrice: "liquidationPrice"
        case .openInterest: "openInterest"
        }
    }
    
    public static func == (lhs: InfoSheetType, rhs: InfoSheetType) -> Bool {
        lhs.id == rhs.id
    }
}
