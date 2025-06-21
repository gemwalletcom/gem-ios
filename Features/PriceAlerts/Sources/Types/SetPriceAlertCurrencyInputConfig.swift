// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import SwiftUI
import Primitives
import Preferences
import Style
import Localization
import Formatters

struct SetPriceAlertCurrencyInputConfig: CurrencyInputConfigurable {
    let type: SetPriceAlertType
    let alertDirection: PriceAlertDirection?
    let assetData: AssetData
    let formatter: CurrencyFormatter
    let onTapActionButton: VoidAction
    let sanitizer: ((String) -> String)? = nil
    
    var placeholder: String {
        switch type {
        case .price: .zero
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
        guard let price = assetData.price?.price else { return .empty }
        return [Localized.PriceAlerts.SetAlert.currentPrice, formatter.string(price)].joined(separator: " ")
    }
    
    var keyboardType: UIKeyboardType { .decimalPad }
    
    var actionStyle: CurrencyInputActionStyle? {
        guard let actionButtonImage else { return nil }
        return CurrencyInputActionStyle(
            position: .amount,
            image: actionButtonImage
        )
    }
    
    private var actionButtonImage: Image? {
        switch (type, alertDirection) {
        case (.percentage, .up): Images.PriceAlert.up
        case (.percentage, .down): Images.PriceAlert.down
        default: nil
        }
    }
}
