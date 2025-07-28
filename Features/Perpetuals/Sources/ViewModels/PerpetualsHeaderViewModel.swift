// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PrimitivesComponents
import Formatters

public struct PerpetualsHeaderViewModel {
    let walletType: WalletType
    let totalValue: Double
    let currencyFormatter: CurrencyFormatter
    
    public init(
        walletType: WalletType,
        totalValue: Double,
        currencyCode: String
    ) {
        self.walletType = walletType
        self.totalValue = totalValue
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: currencyCode)
    }
}

extension PerpetualsHeaderViewModel: HeaderViewModel {
    public var allowHiddenBalance: Bool { true }
    public var isWatchWallet: Bool { walletType == .view }
    public var title: String { currencyFormatter.string(totalValue) }
    public var assetImage: AssetImage? { .none }
    public var subtitle: String? { .none }

    public var buttons: [HeaderButton] {
        [
            HeaderButton(type: .withdraw, isEnabled: false),
            HeaderButton(type: .deposit, isEnabled: true)
        ]
    }
}
