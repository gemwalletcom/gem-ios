import Foundation
import Primitives
import SwiftUI
import Style
import Store
import Components
import PrimitivesComponents

struct AssetDataViewModel {
    private let assetData: AssetData
    let priceViewModel: PriceViewModel
    private let balanceViewModel: BalanceViewModel

    init(
        assetData: AssetData,
        formatter: ValueFormatter
    ) {
        self.assetData = assetData
        self.priceViewModel = PriceViewModel(price: assetData.price)
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
        if [
            Chain.cosmos.assetId,
            Chain.osmosis.assetId,
            Chain.injective.assetId,
            Chain.sei.assetId,
            Chain.celestia.assetId,
            Chain.solana.assetId,
            Chain.sui.assetId,
            Chain.smartChain.assetId,
            Chain.tron.assetId,
//            Chain.ethereum.assetId disabled
        ].contains(asset.id) {
            return true
        }
        return false //assetData.metadata.isStakeEnabled
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
