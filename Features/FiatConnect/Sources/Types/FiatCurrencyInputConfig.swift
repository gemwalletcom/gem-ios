// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

struct FiatCurrencyInputConfig: CurrencyInputConfigurable {
    var secondaryText: String
    var currencySymbol: String

    var currencyPosition: CurrencyTextField.CurrencyPosition { .leading }
    var placeholder: String { .zero }
    var keyboardType: UIKeyboardType { .decimalPad }

    var sanitizer: ((String) -> String)? {
        { input in
            var filtered = input.filter { "0123456789".contains($0) }
            while filtered.first == "0", filtered.count == 1 {
                filtered.removeFirst()
            }
            return filtered
        }
    }

    var actionStyle: CurrencyInputActionStyle? = nil
    let onTapActionButton: VoidAction = nil
}
