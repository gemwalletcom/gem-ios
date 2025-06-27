// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style
import Formatters

public struct InfoSheetViewModel {
    private let type: InfoSheetType

    public init(type: InfoSheetType) {
        self.type = type
    }
}

// MARK: - InfoSheetModelViewable

extension InfoSheetViewModel: InfoSheetModelViewable {
    public var url: URL? {
        switch type {
        case .networkFee: Docs.url(.networkFees)
        case .insufficientNetworkFee: Docs.url(.networkFees)
        case .transactionState: Docs.url(.transactionStatus)
        case .watchWallet: Docs.url(.whatIsWatchWallet)
        case .stakeLockTime: Docs.url(.stakingLockTime)
        case .priceImpact: Docs.url(.priceImpact)
        case .slippage: Docs.url(.slippage)
        case .assetStatus: Docs.url(.tokenVerification)
        case .accountMinimalBalance: Docs.url(.accountMinimalBalance)
        case .insufficientBalance(_): fatalError()
        }
    }

    public var title: String {
        switch type {
        case .networkFee: Localized.Info.NetworkFee.title
        case .insufficientBalance: Localized.Info.InsufficientBalance.title
        case .insufficientNetworkFee(let asset, _): Localized.Info.InsufficientNetworkFeeBalance.title(asset.symbol)
        case .transactionState(_,_, let state):
            switch state {
            case .pending: Localized.Transaction.Status.pending
            case .confirmed: Localized.Transaction.Status.confirmed
            case .failed: Localized.Transaction.Status.failed
            case .reverted: Localized.Transaction.Status.reverted
            }
        case .watchWallet: Localized.Info.WatchWallet.title
        case .stakeLockTime: Localized.Stake.lockTime
        case .priceImpact: Localized.Info.PriceImpact.title
        case .slippage: Localized.Swap.slippage
        case .assetStatus(let status):
            switch status {
            case .verified: .empty // verified token status isn't displayed on the asset screen.
            case .suspicious: Localized.Asset.Verification.suspicious
            case .unverified: Localized.Asset.Verification.unverified
            }
        case .accountMinimalBalance: Localized.Info.AccountMinimumBalance.title
        }
    }

    public var description: String {
        switch type {
        case .networkFee(let chain): return Localized.Info.NetworkFee.description(chain.asset.name, chain.asset.symbol)
        case .insufficientBalance(let asset): return Localized.Info.InsufficientBalance.description(asset.symbol)
        case .insufficientNetworkFee(let asset, let required):
            let amount = ValueFormatter(style: .short).string(required, asset: asset)
            return Localized.Info.InsufficientNetworkFeeBalance.description(
                "**\(amount)**",
                asset.name,
                asset.symbol
            )
        case .transactionState(_, _, let state):
            switch state {
            case .pending: return Localized.Info.Transaction.Pending.description
            case .confirmed: return Localized.Info.Transaction.Success.description
            case .failed, .reverted: return Localized.Info.Transaction.Error.description
            }
        case .watchWallet: return Localized.Info.WatchWallet.description
        case .stakeLockTime: return Localized.Info.LockTime.description
        case .priceImpact: return Localized.Info.PriceImpact.description
        case .slippage: return Localized.Info.Slippage.description
        case .assetStatus(let status):
            switch status {
            case .verified: return .empty // verified token status isn't displayed on the asset screen.
            case .unverified: return Localized.Info.AssetStatus.Unverified.description
            case .suspicious: return Localized.Info.AssetStatus.Suspicious.description
            }
        case .accountMinimalBalance(let asset, let required):
            let amount = ValueFormatter(style: .auto).string(required, asset: asset)
            return Localized.Transfer.minimumAccountBalance(amount)
        }
    }

    public var image: InfoSheetImage? {
        switch type {
        case .networkFee, .insufficientNetworkFee: return .image(Images.Info.networkFee)
        case .insufficientBalance: return .none
        case .transactionState(let imageURL, let placeholder, let state):
            let stateImage = switch state {
            case .pending: Images.Transaction.State.pending
            case .confirmed: Images.Transaction.State.success
            case .failed, .reverted: Images.Transaction.State.error
            }
            return .assetImage(
                AssetImage(
                    imageURL: imageURL,
                    placeholder: placeholder,
                    chainPlaceholder: stateImage
                )
            )
        case .watchWallet:
            return .assetImage(
                AssetImage(
                    imageURL: .none,
                    placeholder: Images.Logo.logo,
                    chainPlaceholder: Images.Wallets.watch
                )
            )
        case .stakeLockTime(let image):
            return .assetImage(AssetImage(
                imageURL: .none,
                placeholder: image,
                chainPlaceholder: .none
            ))
        case .priceImpact:
            return .image(Images.Logo.logo)
        case .slippage:
            return .image(Images.Logo.logo)
        case .accountMinimalBalance:
            return .image(Images.Logo.logo)
        case .assetStatus(let status):
            switch status {
            case .verified: return .image(Images.Logo.logo)
            case .unverified: return .image(Images.TokenStatus.warning)
            case .suspicious: return .image(Images.TokenStatus.risk)
            }
        }
    }
    
    public var buttonTitle: String { Localized.Common.learnMore }
}
