// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Primitives
import PrimitivesComponents
import Formatters
import Localization
import Style

struct PerpetualsHeaderViewModel {
    let walletType: WalletType
    let balance: WalletBalance
    let currencyFormatter: CurrencyFormatter
    let currency = Currency.usd.rawValue
    
    init(
        walletType: WalletType,
        balance: WalletBalance
    ) {
        self.walletType = walletType
        self.balance = balance
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: currency)
    }
}

extension PerpetualsHeaderViewModel: HeaderViewModel {
    var isWatchWallet: Bool { walletType == .view }
    var title: String { currencyFormatter.string(balance.total) }
    var assetImage: AssetImage? { .none }
    var subtitle: String? {
        Localized.Wallet
            .availableBalance(currencyFormatter.string(balance.available))
    }
    var subtitleColor: Color { Colors.gray }

    var buttons: [HeaderButton] {
        [
            HeaderButton(type: .withdraw, isEnabled: isWithdrawEnabled),
            HeaderButton(type: .deposit, isEnabled: true)
        ]
    }

    private var isWithdrawEnabled: Bool {
        balance.available > 0
    }
}
