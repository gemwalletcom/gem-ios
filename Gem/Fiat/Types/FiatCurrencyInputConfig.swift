// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

struct FiatCurrencyInputConfig: CurrencyInputConfigurable {
    let type: FiatTransactionType
    let assetAddress: AssetAddress
    var secondaryText: String

    init(
        type: FiatTransactionType,
        assetAddress: AssetAddress,
        secondaryText: String
    ) {
        self.type = type
        self.assetAddress = assetAddress
        self.secondaryText = secondaryText
    }

    var currencyPosition: CurrencyTextField.CurrencyPosition {
        switch type {
        case .buy: .leading
        case .sell: .trailing
        }
    }

    var placeholder: String { "0" }

    var currencySymbol: String {
        switch type {
        case .buy: "$"
        case .sell: assetAddress.asset.symbol
        }
    }

    var keyboardType: UIKeyboardType {
        switch type {
        case .buy: .numberPad
        case .sell: .decimalPad
        }
    }
}
