// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import SwiftUI
import Primitives
import Preferences

struct SetPriceAlertCurrencyInputConfig: CurrencyInputConfigurable {
    let type: SetPriceAlertType
    let assetData: AssetData
    let formatter: CurrencyFormatter
    
    var placeholder: String {
        switch type {
        case .price: .empty
        case .percentage: "5"
        }
    }

    var currencySymbol: String {
        switch type {
        case .price: formatter.symbol
        case .percentage: "%"
        }
    }
    
    var currencyPosition: Components.CurrencyTextField.CurrencyPosition {
        switch type {
        case .price: .leading
        case .percentage: .trailing
        }
    }
    
    var secondaryText: String {
        guard let price = assetData.price?.price else {
            return .empty
        }
        return ["Current price", formatter.string(price)].joined(separator: " ")
    }
    
    var keyboardType: UIKeyboardType {
        .decimalPad
    }
    
    var sanitizer: ((String) -> String)? = { input in
        input.components(separatedBy: .whitespacesAndNewlines).joined()
    }
}
