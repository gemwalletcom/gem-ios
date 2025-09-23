// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PrimitivesComponents
import Formatters
import Localization

public struct PerpetualsHeaderViewModel {
    let walletType: WalletType
    let balance: WalletBalance
    let currencyFormatter: CurrencyFormatter
    let currency = Currency.usd.rawValue
    
    public init(
        walletType: WalletType,
        balance: WalletBalance
    ) {
        self.walletType = walletType
        self.balance = balance
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: currency)
    }
}

extension PerpetualsHeaderViewModel: HeaderViewModel {
    public var allowHiddenBalance: Bool { true }
    public var isWatchWallet: Bool { walletType == .view }
    public var title: String { currencyFormatter.string(balance.total) }
    public var assetImage: AssetImage? { .none }
    public var subtitle: String? {
        Localized.Wallet
            .availableBalance(currencyFormatter.string(balance.available))
    }

    public var buttons: [HeaderButton] {
        [
            HeaderButton(type: .withdraw, isEnabled: isWithdrawEnabled),
            HeaderButton(type: .deposit, isEnabled: true)
        ]
    }

    private var isWithdrawEnabled: Bool {
        balance.available > 0
    }
}
