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
    
    public init(
        walletType: WalletType,
        balance: WalletBalance,
        currencyCode: String
    ) {
        self.walletType = walletType
        self.balance = balance
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: currencyCode)
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
            HeaderButton(type: .withdraw, isEnabled: false),
            HeaderButton(type: .deposit, isEnabled: true)
        ]
    }
}
