// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Store
import Primitives
import BigInt
import Style
import Components

struct WalletHeaderViewModel {
    //Remove WalletType from here
    let walletType: WalletType
    let value: WalletFiatValue
    let currencyFormatter = CurrencyFormatter.currency()
    
    public init(
        walletType: WalletType,
        value: WalletFiatValue
    ) {
        self.walletType = walletType
        self.value = value
    }
    
    var priceViewModel: PriceViewModel {
        return PriceViewModel(
            price: Price(price: value.price, priceChangePercentage24h: value.priceChangePercentage24h)
        )
    }
    
    public var totalValueText: String {
        return currencyFormatter.string(value.totalValue)
    }
    
    // totalPrice
    public var totalPrice: String {
        return priceViewModel.priceAmountPositiveText
    }
    
    public var totalPriceColor: Color {
        return priceViewModel.priceAmountColor
    }
    
    // price change
    public var totalPriceChange: String {
        return priceViewModel.priceChangeText
    }
    
    public var totalPriceChangeBackground: Color {
        return priceViewModel.priceChangeTextBackgroundColor
    }
    
    public var totalPriceChangeColor: Color {
        return priceViewModel.priceChangeTextColor
    }
}

extension WalletHeaderViewModel: HeaderViewModel {
    
    var isWatchWallet: Bool {
        walletType == .view
    }
    
    var assetImage: AssetImage? {
        return .none
    }
    
    var title: String {
        return totalValueText
    }
    
    var subtitle: String? {
        return .none
    }
    
    var buttons: [HeaderButton] {
        let values: [(type: HeaderButtonType, isShown: Bool)] = [
            (.send, true),
            (.receive, true),
            (.buy, true),
        ]
        return values.compactMap {
            if $0.isShown {
                return HeaderButton(type: $0.type)
            }
            return .none
        }
    }
}
