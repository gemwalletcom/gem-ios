// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import SwiftUI
import Style
import WalletsService
import BigInt

struct AmountInputConfig: CurrencyInputConfigurable {
    let type: AmountInputType
    let asset: Asset
    let currencyFormatter: CurrencyFormatter
    let numberSanitizer: NumberSanitizer
    let secondaryText: String
    let onTapActionButton: (() -> Void)?    
    
    var placeholder: String { .zero }
    var keyboardType: UIKeyboardType { .decimalPad }
    var actionButtonImage: Image? { Images.Actions.swap.renderingMode(.template) }

    var currencyPosition: CurrencyTextField.CurrencyPosition {
        switch type {
        case .asset: .trailing
        case .fiat: .leading
        }
    }

    var currencySymbol: String {
        switch type {
        case .asset: asset.symbol
        case .fiat: currencyFormatter.symbol
        }
    }

    var sanitizer: ((String) -> String)? {
        { numberSanitizer.sanitize($0) }
    }
}
