// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components

public struct AssetDataViewModel {
    private let assetData: AssetData
    private let balanceViewModel: BalanceViewModel

    public let priceViewModel: PriceViewModel
    let currencyCode: String

    public init(
        assetData: AssetData,
        formatter: ValueFormatter,
        currencyCode: String
    ) {
        self.assetData = assetData
        self.priceViewModel = PriceViewModel(
            price: assetData.price,
            currencyCode: currencyCode
        )
        self.balanceViewModel = BalanceViewModel(
            asset: assetData.asset,
            balance: assetData.balance,
            formatter: formatter
        )
        self.currencyCode = currencyCode
    }

    // asset

    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: asset.id).assetImage
    }

    public var asset: Asset {
        assetData.asset
    }

    public var name: String {
        assetData.asset.name
    }

    public var symbol: String {
        assetData.asset.symbol
    }

    // price

    public var isPriceAvailable: Bool {
        priceViewModel.isPriceAvailable
    }

    public var priceAmountText: String {
        priceViewModel.priceAmountText
    }

    public var priceChangeText: String {
        priceViewModel.priceChangeText
    }

    public var priceChangeTextColor: Color {
        priceViewModel.priceChangeTextColor
    }

    // balance

    public var balanceText: String {
        balanceViewModel.balanceText
    }

    public var availableBalanceText: String {
        balanceViewModel.availableBalanceText
    }

    public var totalBalanceTextWithSymbol: String {
        balanceViewModel.totalBalanceTextWithSymbol
    }

    public var availableBalanceTextWithSymbol: String {
        balanceViewModel.availableBalanceTextWithSymbol
    }

    public var stakeBalanceTextWithSymbol: String {
        balanceViewModel.stakingBalanceTextWithSymbol
    }

    public var hasReservedBalance: Bool {
        balanceViewModel.hasReservedBalance
    }

    public var hasAvailableBalance: Bool {
        balanceViewModel.availableBalanceAmount > 0
    }

    public var reservedBalanceTextWithSymbol: String {
        balanceViewModel.reservedBalanceTextWithSymbol
    }

    public var balanceTextColor: Color {
        balanceViewModel.balanceTextColor
    }

    public var fiatBalanceText: String {
        guard let price = priceViewModel.price else {
            return .empty
        }
        let value = balanceViewModel.balanceAmount * price.price
        return CurrencyFormatter(
            type: .currency,
            currencyCode: currencyCode
        ).string(value)
    }

    public var isEnabled: Bool {
        assetData.metadata.isEnabled
    }

    public var isBuyEnabled: Bool {
        assetData.metadata.isBuyEnabled
    }

    public var isSellEnabled: Bool {
        assetData.metadata.isSellEnabled
    }

    public var isSwapEnabled: Bool {
        assetData.metadata.isSwapEnabled
    }

    public var isStakeEnabled: Bool {
        assetData.metadata.isStakeEnabled
    }

    public var isActive: Bool {
        assetData.metadata.isActive
    }

    public var address: String {
        assetData.account.address
    }

    public var showBalances: Bool {
        assetData.balances.contains(where: { $0.key != .available && $0.value > 0 })
    }

    public var stakeApr: Double? {
        assetData.metadata.stakingApr
    }
    
    public var isPriceAlertsEnabled: Bool {
        assetData.isPriceAlertsEnabled
    }
}
