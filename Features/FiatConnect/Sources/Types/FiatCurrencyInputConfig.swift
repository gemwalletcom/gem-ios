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
        .decimalPad
    }

    var sanitizer: ((String) -> String)? {
        switch type {
        case .buy:
            return { input in
                var filtered = input.filter { "0123456789".contains($0) }
                while filtered.first == "0", filtered.count == 1 {
                    filtered.removeFirst()
                }
                return filtered
            }
        case .sell:
            return .none
        }
    }
    
    let actionButtonImage: Image? = nil
    let onTapActionButton: VoidAction = nil
}
