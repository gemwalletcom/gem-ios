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
        {
            guard let separator = Locale.current.decimalSeparator?.first else { return $0 }
            let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: String(separator)))

            let cleanedInput = $0.filter { !$0.isWhitespace && !$0.isSymbol }
            var sanitized = cleanedInput.filter { $0.unicodeScalars.allSatisfy(allowedCharacters.contains) }

            if let firstSeparatorIndex = sanitized.firstIndex(of: separator) {
                let beforeSeparator = sanitized.prefix(upTo: firstSeparatorIndex)
                let afterSeparator = sanitized.dropFirst(firstSeparatorIndex.utf16Offset(in: sanitized) + 1)
                    .replacingOccurrences(of: String(separator), with: "")
                
                sanitized = beforeSeparator + String(separator) + afterSeparator
            }

            return sanitized
        }
    }
}
