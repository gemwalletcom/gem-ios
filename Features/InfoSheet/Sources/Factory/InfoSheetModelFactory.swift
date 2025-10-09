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
import PrimitivesComponents

public struct InfoSheetModelFactory {
    
    public static func create(from type: InfoSheetType) -> InfoSheetModel {
        switch type {
        case let .networkFee(chain):
            return InfoSheetModel(
                title: Localized.Info.NetworkFee.title,
                description: Localized.Info.NetworkFee.description(chain.asset.name, chain.asset.symbol),
                image: .image(Images.Info.networkFee),
                button: .url(Docs.url(.networkFees))
            )
        case let .insufficientBalance(asset, image):
            return InfoSheetModel(
                title: Localized.Info.InsufficientBalance.title,
                description: Localized.Info.InsufficientBalance.description(asset.symbol),
                image: .assetImage(image)
            )
        case let .insufficientNetworkFee(asset, image, required, action):
            let formatter = ValueFormatter(style: .full)
            let description = if let required = required {
                Localized.Info.InsufficientNetworkFeeBalance.description(
                    formatter.string(required, decimals: asset.chain.asset.decimals.asInt, currency: asset.chain.asset.symbol).wrap("**"),
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
                button: .action(title: Localized.Asset.buyAsset(asset.feeAsset.symbol), action: action)
            )
        case let .transactionState(imageURL, placeholder, state):
            let model = TransactionStateViewModel(state: state)
            return InfoSheetModel(
                title: model.title,
                description: model.description,
                image: .assetImage(AssetImage(imageURL: imageURL, placeholder: placeholder, chainPlaceholder: model.stateImage)),
                button: .url(Docs.url(.transactionStatus))
            )
        case .watchWallet:
            return InfoSheetModel(
                title: Localized.Info.WatchWallet.title,
                description: Localized.Info.WatchWallet.description,
                image: .image(Images.Wallets.watch),
                button: .url(Docs.url(.whatIsWatchWallet))
            )
        case let .stakeLockTime(placeholder):
            return InfoSheetModel(
                title: Localized.Stake.lockTime,
                description: Localized.Info.LockTime.description,
                image: placeholder.map { .image($0) },
                button: .url(Docs.url(.stakingLockTime))
            )
        case .priceImpact:
            return InfoSheetModel(
                title: Localized.Swap.priceImpact,
                description: Localized.Info.PriceImpact.description,
                image: .image(Images.Logo.logo),
                button: .url(Docs.url(.priceImpact))
            )
        case .slippage:
            return InfoSheetModel(
                title: Localized.Swap.slippage,
                description: Localized.Info.Slippage.description,
                image: .image(Images.Logo.logo),
                button: .url(Docs.url(.slippage))
            )
        case .noQuote:
            return InfoSheetModel(
                title: Localized.Errors.Swap.noQuoteAvailable,
                description: Localized.Info.NoQuote.description,
                image: .image(Images.Logo.logo),
                button: .url(Docs.url(.noQuotes))
            )
        case let .assetStatus(scoreType):
            let model = AssetScoreTypeViewModel(scoreType: scoreType)
            return InfoSheetModel(
                title: model.status,
                description: model.description,
                image: .assetImage(model.assetImage),
                button: .url(model.docsUrl)
            )
        case let .accountMinimalBalance(asset, required):
            let formatter = ValueFormatter(style: .full)
            let amount = formatter.string(required, asset: asset)
            return InfoSheetModel(
                title: Localized.Info.AccountMinimumBalance.title,
                description: Localized.Transfer.minimumAccountBalance(amount),
                image: .image(Images.Logo.logo),
                button: .url(Docs.url(.accountMinimalBalance))
            )
        case let .stakeMinimumAmount(asset, required, action):
            let formatter = ValueFormatter(style: .full)
            let amount = formatter.string(required, asset: asset)
            return InfoSheetModel(
                title: Localized.Info.StakeMinimumAmount.title,
                description: Localized.Info.StakeMinimumAmount.description(asset.name, amount),
                image: .image(Images.Logo.logo),
                button: .action(title: Localized.Asset.buyAsset(asset.feeAsset.symbol), action: action)
            )
        case let .stakingReservedFees(image):
            return InfoSheetModel(
                title: Localized.Info.Stake.Reserved.title,
                description: Localized.Info.Stake.Reserved.description,
                image: .assetImage(image),
                button: .url(Docs.url(.networkFees))
            )
        case .fundingRate:
            return InfoSheetModel(
                title: Localized.Info.FundingRate.title,
                description: Localized.Info.FundingRate.description,
                image: .image(Images.Logo.logo),
                button: .url(Docs.url(.perpetualsFundingRate))
            )
        case .fundingPayments:
            return InfoSheetModel(
                title: Localized.Info.FundingPayments.title,
                description: Localized.Info.FundingPayments.description,
                image: .image(Images.Logo.logo),
                button: .url(Docs.url(.perpetualsFundingPayments))
            )
        case .liquidationPrice:
            return InfoSheetModel(
                title: Localized.Info.LiquidationPrice.title,
                description: Localized.Info.LiquidationPrice.description,
                image: .image(Images.Logo.logo),
                button: .url(Docs.url(.perpetualsLiquidationPrice))
            )
        case .openInterest:
            return InfoSheetModel(
                title: Localized.Info.OpenInterest.title,
                description: Localized.Info.OpenInterest.description,
                image: .image(Images.Logo.logo),
                button: .url(Docs.url(.perpetualsOpenInterest))
            )
        }
    }
}
