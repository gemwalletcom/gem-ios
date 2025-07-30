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
    case insufficientNetworkFee(Asset, image: AssetImage, required: BigInt?)
    case transactionState(imageURL: URL?, placeholder: Image?, state: TransactionState)
    case watchWallet
    case stakeLockTime(Image?)
    // swaps
    case priceImpact
    case slippage
    case noQuote
    // asset
    case assetStatus(AssetScoreType)
    case accountMinimalBalance(Asset, required: BigInt)
    // stake
    case stakeMinimumAmount(Asset, required: BigInt)
    // perpetuals
    case fundingRate
    case fundingPayments
    case liquidationPrice
    case openInterest


    public var id: String {
        switch self {
        case .networkFee: "networkFees"
        case .insufficientNetworkFee: "insufficientNetworkFee"
        case .insufficientBalance(let asset, _): "insufficientBalance_\(asset.id.identifier)"
        case .transactionState(_, _, let state): state.id
        case .watchWallet: "watchWallet"
        case .stakeLockTime: "stakeLockTime"
        case .priceImpact: "priceImpact"
        case .slippage: "slippage"
        case .assetStatus(let status): "assetStatus_\(status.rawValue)"
        case let .accountMinimalBalance(asset, amount): "accountMinimalBalance_\(asset.id.identifier)\(amount)"
        case let .stakeMinimumAmount(asset, amount): "stakeMinimumAmount_\(asset.id.identifier)\(amount)"
        case .noQuote: "noQuote"
        case .fundingRate: "fundingRate"
        case .fundingPayments: "fundingPayments"
        case .liquidationPrice: "liquidationPrice"
        case .openInterest: "openInterest"
        }
    }
    
    public func model(button: InfoSheetButton? = nil) -> InfoSheetModel {
        switch self {
        case let .networkFee(chain):
            return InfoSheetModel(
                title: Localized.Info.NetworkFee.title,
                description: Localized.Info.NetworkFee.description(chain.asset.name, chain.asset.symbol),
                image: .image(Images.Info.networkFee),
                button: button ?? .url(Docs.url(.networkFees)),
                buttonTitle: Localized.Common.learnMore
            )
        case let .insufficientBalance(asset, image):
            return InfoSheetModel(
                title: Localized.Info.InsufficientBalance.title,
                description: Localized.Info.InsufficientBalance.description(asset.symbol),
                image: .assetImage(image),
                button: button,
                buttonTitle: {
                    switch button {
                    case .action(let title, _): return title
                    case .url, .none: return Localized.Wallet.buy
                    }
                }()
            )
        case let .insufficientNetworkFee(asset, image, required):
            let formatter = ValueFormatter(style: .full)
            let description = if let required = required {
                Localized.Info.InsufficientNetworkFeeBalance.description(
                    formatter.string(required, decimals: asset.chain.asset.decimals.asInt),
                    asset.chain.asset.name,
                    asset.chain.asset.symbol
                )
            } else {
                Localized.Info.InsufficientNetworkFeeBalance.description("", asset.chain.asset.name, asset.chain.asset.symbol)
            }
            return InfoSheetModel(
                title: Localized.Info.InsufficientNetworkFeeBalance.title(asset.chain.asset.symbol),
                description: description,
                image: .assetImage(image),
                button: button,
                buttonTitle: {
                    switch button {
                    case .action(let title, _): return title
                    case .url, .none: return Localized.Wallet.buy
                    }
                }()
            )
        case let .transactionState(imageURL, placeholder, state):
            let stateImage = switch state {
            case .pending: Images.Transaction.State.pending
            case .confirmed: Images.Transaction.State.success
            case .failed, .reverted: Images.Transaction.State.error
            }
            let image: InfoSheetImage = .assetImage(
                AssetImage(
                    imageURL: imageURL,
                    placeholder: placeholder,
                    chainPlaceholder: stateImage
                )
            )
            let title = switch state {
            case .pending: Localized.Transaction.Status.pending
            case .confirmed: Localized.Transaction.Status.confirmed
            case .failed: Localized.Transaction.Status.failed
            case .reverted: Localized.Transaction.Status.reverted
            }
            let description = switch state {
            case .pending: Localized.Info.Transaction.Pending.description
            case .confirmed: Localized.Info.Transaction.Success.description
            case .failed, .reverted: Localized.Info.Transaction.Error.description
            }
            return InfoSheetModel(
                title: title,
                description: description,
                image: image
            )
        case .watchWallet:
            return InfoSheetModel(
                title: Localized.Info.WatchWallet.title,
                description: Localized.Info.WatchWallet.description,
                image: nil
            )
        case let .stakeLockTime(placeholder):
            return InfoSheetModel(
                title: Localized.Stake.lockTime,
                description: Localized.Info.LockTime.description,
                image: placeholder.map { .image($0) }
            )
        case .priceImpact:
            return InfoSheetModel(
                title: Localized.Swap.priceImpact,
                description: Localized.Info.PriceImpact.description,
                image: .image(Images.Logo.logo),
                button: button ?? .url(Docs.url(.priceImpact)),
                buttonTitle: Localized.Common.learnMore
            )
        case .slippage:
            return InfoSheetModel(
                title: Localized.Swap.slippage,
                description: Localized.Info.Slippage.description,
                image: .image(Images.Logo.logo),
                button: button ?? .url(Docs.url(.slippage)),
                buttonTitle: Localized.Common.learnMore
            )
        case .noQuote:
            return InfoSheetModel(
                title: Localized.Errors.Swap.noQuoteAvailable,
                description: Localized.Info.NoQuote.description,
                image: .image(Images.Logo.logo)
            )
        case let .assetStatus(status):
            let image: InfoSheetImage = switch status {
            case .verified: .image(Images.Logo.logo)
            case .unverified: .image(Images.TokenStatus.warning)
            case .suspicious: .image(Images.TokenStatus.risk)
            }
            let title = switch status {
            case .verified: String.empty
            case .unverified: Localized.Asset.Verification.unverified
            case .suspicious: Localized.Asset.Verification.suspicious
            }
            let description = switch status {
            case .verified: String.empty
            case .unverified: Localized.Info.AssetStatus.Unverified.description
            case .suspicious: Localized.Info.AssetStatus.Suspicious.description
            }
            return InfoSheetModel(
                title: title,
                description: description,
                image: image
            )
        case let .accountMinimalBalance(asset, required):
            let formatter = ValueFormatter(style: .full)
            let amount = formatter.string(required, asset: asset)
            return InfoSheetModel(
                title: Localized.Info.AccountMinimumBalance.title,
                description: Localized.Transfer.minimumAccountBalance(amount),
                image: .image(Images.Logo.logo),
                button: button,
                buttonTitle: {
                    switch button {
                    case .action(let title, _): return title
                    case .url, .none: return Localized.Common.done
                    }
                }()
            )
        case let .stakeMinimumAmount(asset, required):
            let formatter = ValueFormatter(style: .full)
            let amount = formatter.string(required, asset: asset)
            return InfoSheetModel(
                title: Localized.Info.StakeMinimumAmount.title,
                description: Localized.Info.StakeMinimumAmount.description(asset.name, amount),
                image: .image(Images.Logo.logo),
                button: button,
                buttonTitle: {
                    switch button {
                    case .action(let title, _): return title
                    case .url, .none: return Localized.Common.done
                    }
                }()
            )
        case .fundingRate:
            return InfoSheetModel(
                title: Localized.Info.FundingRate.title,
                description: Localized.Info.FundingRate.description,
                image: .image(Images.Logo.logo)
            )
        case .fundingPayments:
            return InfoSheetModel(
                title: Localized.Info.FundingPayments.title,
                description: Localized.Info.FundingPayments.description,
                image: .image(Images.Logo.logo)
            )
        case .liquidationPrice:
            return InfoSheetModel(
                title: Localized.Info.LiquidationPrice.title,
                description: Localized.Info.LiquidationPrice.description,
                image: .image(Images.Logo.logo)
            )
        case .openInterest:
            return InfoSheetModel(
                title: Localized.Info.OpenInterest.title,
                description: Localized.Info.OpenInterest.description,
                image: .image(Images.Logo.logo)
            )
        }
    }
}
