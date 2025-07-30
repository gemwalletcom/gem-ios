// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style
import Formatters

public struct InfoSheetFactory {
    
    public static func viewModel(for type: InfoSheetType, button: InfoSheetButton? = nil) -> any InfoSheetModelViewable {
        switch type {
        case let .networkFee(chain): NetworkFeeInfoSheetViewModel(chain: chain)
        case let .insufficientBalance(asset, image): InsufficientBalanceInfoSheetViewModel(asset: asset, assetImage: image, button: button)
        case let .insufficientNetworkFee(asset, image, required): InsufficientNetworkFeeInfoSheetViewModel(asset: asset, assetImage: image, required: required, button: button)
        case let .transactionState(imageURL, placeholder, state): TransactionStateInfoSheetViewModel(imageURL: imageURL, placeholder: placeholder, state: state)
        case .watchWallet: WatchWalletInfoSheetViewModel()
        case let .stakeLockTime(image): StakeLockTimeInfoSheetViewModel(placeholder: image)
        case .priceImpact: PriceImpactInfoSheetViewModel()
        case .slippage: SlippageInfoSheetViewModel()
        case let .assetStatus(status): AssetStatusInfoSheetViewModel(status: status)
        case let .accountMinimalBalance(asset, required): AccountMinimalBalanceInfoSheetViewModel(asset: asset, required: required, button: button)
        case let .stakeMinimumAmount(asset, required): StakeMinimumAmountInfoSheetViewModel(asset: asset, required: required, button: button)
        case .noQuote: NoQuoteInfoSheetViewModel()
        case .fundingRate: FundingRateInfoSheetViewModel()
        case .fundingPayments: FundingPaymentsInfoSheetViewModel()
        case .liquidationPrice: LiquidationPriceInfoSheetViewModel()
        case .openInterest: OpenInterestInfoSheetViewModel()
        }
    }
}
