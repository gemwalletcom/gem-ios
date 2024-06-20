import Foundation
import Primitives
import SwiftUI
import Style
import Store
import Components

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
        return priceViewModel.isPriceAvailable
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
    
    var reservedBalanceTextWithSymbol: String {
        balanceViewModel.reservedBalanceTextWithSymbol
    }
    
    var balanceTextColor: Color {
        return balanceViewModel.balanceTextColor
    }
    
    var fiatBalanceText: String {
        guard let price = priceViewModel.price else {
            return .empty
        }
        let value = balanceViewModel.balanceAmount * price.price
        return CurrencyFormatter.currency().string(value)
    }
    
    var isEnabled: Bool {
        return assetData.metadata.isEnabled
    }
    
    var isBuyEnabled: Bool {
        return assetData.metadata.isBuyEnabled
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
//            Chain.ethereum.assetId disabled
        ].contains(asset.id) {
            return true
        }
        return false //assetData.metadata.isStakeEnabled
    }
    
    var address: String {
        return assetData.account.address
    }
    
    var showBalances: Bool {
        return assetData.balances.filter { $0.value > 0 }.count > 1
    }
    
    var stakeApr: Double? {
        assetData.details?.details.stakingApr
    }
}
