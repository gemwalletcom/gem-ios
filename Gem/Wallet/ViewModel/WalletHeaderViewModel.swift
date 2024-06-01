// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Store
import Primitives
import BigInt
import Style
import Components

struct WalletHeaderViewModel {
    let walletModel: WalletViewModel
    let value: WalletFiatValue
    let currencyFormatter = CurrencyFormatter.currency()
    
    public init(
        walletModel: WalletViewModel,
        value: WalletFiatValue
    ) {
        self.walletModel = walletModel
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
        walletModel.wallet.type == .view
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
        let values: [(type: HeaderButtonType, isDisabled: Bool, isShown: Bool)] = [
            (.send, walletModel.isButtonDisabled(type: .send), true),
            (.receive, walletModel.isButtonDisabled(type: .receive), true),
            (.buy, walletModel.isButtonDisabled(type: .buy), Preferences.standard.isPushNotificationsEnabled),
            (.swap, walletModel.isButtonDisabled(type: .swap), Preferences.standard.isPushNotificationsEnabled),
        ]
        return values.compactMap {
            if $0.isShown {
                return HeaderButton(type: $0.type, isDisabled: $0.isDisabled)
            }
            return .none
        }
    }
}
