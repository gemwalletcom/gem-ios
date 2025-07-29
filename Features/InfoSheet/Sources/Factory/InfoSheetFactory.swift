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
        case .networkFee(let chain): NetworkFeeInfoSheetViewModel(chain: chain)
        case .insufficientBalance(let asset, let image): InsufficientBalanceInfoSheetViewModel(asset: asset, assetImage: image, button: button)
        case .insufficientNetworkFee(let asset, let image, let required): InsufficientNetworkFeeInfoSheetViewModel(asset: asset, assetImage: image, required: required, button: button)
        case .transactionState(let imageURL, let placeholder, let state): TransactionStateInfoSheetViewModel(imageURL: imageURL, placeholder: placeholder, state: state)
        case .watchWallet: WatchWalletInfoSheetViewModel()
        case .stakeLockTime(let image): StakeLockTimeInfoSheetViewModel(placeholder: image)
        case .priceImpact: PriceImpactInfoSheetViewModel()
        case .slippage: SlippageInfoSheetViewModel()
        case .assetStatus(let status): AssetStatusInfoSheetViewModel(status: status)
        case .accountMinimalBalance(let asset, let required): AccountMinimalBalanceInfoSheetViewModel(asset: asset, required: required, button: button)
        case .stakeMinimumAmount(let asset, let required): StakeMinimumAmountInfoSheetViewModel(asset: asset, required: required, button: button)
        case .noQuote: NoQuoteInfoSheetViewModel()
        case .fundingRate: FundingRateInfoSheetViewModel()
        case .fundingPayments: FundingPaymentsInfoSheetViewModel()
        case .liquidationPrice: LiquidationPriceInfoSheetViewModel()
        case .openInterest: OpenInterestInfoSheetViewModel()
        }
    }
}
