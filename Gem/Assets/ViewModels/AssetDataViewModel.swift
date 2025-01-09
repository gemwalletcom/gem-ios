import Foundation
import Primitives
import SwiftUI
import Style
import Store
import Components
import PrimitivesComponents
import struct GemstonePrimitives.GemstoneConfig

struct AssetDataViewModel {
    private let assetData: AssetData
    private let balanceViewModel: BalanceViewModel

    let priceViewModel: PriceViewModel

    init(
        assetData: AssetData,
        formatter: ValueFormatter,
        preferences: Preferences = Preferences.standard
    ) {
        self.assetData = assetData
        self.priceViewModel = PriceViewModel(
            price: assetData.price,
            currencyCode: preferences.currency
        )
        self.balanceViewModel = BalanceViewModel(
            asset: assetData.asset,
            balance: assetData.balance,
            formatter: formatter
        )
    }
    
    // asset
    
    public var assetImage: AssetImage {
        return AssetIdViewModel(assetId: asset.id).assetImage
    }
    
    var asset: Asset {
        assetData.asset
    }
    
    var name: String {
        assetData.asset.name
    }
    
    var symbol: String {
        assetData.asset.symbol
    }

    // price
    
    var isPriceAvailable: Bool {
        priceViewModel.isPriceAvailable
    }
    
    var priceAmountText: String {
        priceViewModel.priceAmountText
    }

    var priceChangeText: String {
        priceViewModel.priceChangeText
    }
    
    var priceChangeTextColor: Color {
        priceViewModel.priceChangeTextColor
    }
    
    // balance
    
    var balanceText: String {
        balanceViewModel.balanceText
    }
    
    var availableBalanceText: String {
        balanceViewModel.availableBalanceText
    }
    
    var totalBalanceTextWithSymbol: String {
        balanceViewModel.totalBalanceTextWithSymbol
    }
    
    var availableBalanceTextWithSymbol: String {
        balanceViewModel.availableBalanceTextWithSymbol
    }
    
    var stakeBalanceTextWithSymbol: String {
        balanceViewModel.stakingBalanceTextWithSymbol
    }
    
    var hasReservedBalance: Bool {
        balanceViewModel.hasReservedBalance
    }

    var hasAvailableBalance: Bool {
        balanceViewModel.availableBalanceAmount > 0
    }

    var reservedBalanceTextWithSymbol: String {
        balanceViewModel.reservedBalanceTextWithSymbol
    }
    
    var balanceTextColor: Color {
        balanceViewModel.balanceTextColor
    }
    
    var fiatBalanceText: String {
        guard let price = priceViewModel.price else {
            return .empty
        }
        let value = balanceViewModel.balanceAmount * price.price
        return CurrencyFormatter.currency().string(value)
    }
    
    var isEnabled: Bool {
        assetData.metadata.isEnabled
    }
    
    var isBuyEnabled: Bool {
        assetData.metadata.isBuyEnabled
    }

    var isSellEnabled: Bool {
        assetData.metadata.isSellEnabled
    }

    var isSwapEnabled: Bool {
        return assetData.metadata.isSwapEnabled
    }
    
    var isStakeEnabled: Bool {
        GemstoneConfig.shared.getChainConfig(chain: assetData.asset.chain.rawValue).isStakeSupported
    }
    
    var isActive: Bool {
        assetData.metadata.isActive
    }
    
    var address: String {
        return assetData.account.address
    }
    
    var showBalances: Bool {
        return assetData.balances.contains(where: { $0.key != .available && $0.value > 0 })
    }
    
    var stakeApr: Double? {
        assetData.metadata.stakingApr
    }
}
