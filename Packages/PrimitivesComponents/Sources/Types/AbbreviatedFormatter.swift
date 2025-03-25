// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import UIKit

public struct AbbreviatedFormatter: Sendable {
    private let currencyFormatter: CurrencyFormatter
    private let locale: Locale
    
    public init(
        locale: Locale = Locale.current,
        currencyFormatter: CurrencyFormatter
    ) {
        self.locale = locale
        self.currencyFormatter = currencyFormatter
    }
    
    // MARK: - Public methods
    
    public func string(_ amount: Double, symbol: String? = .none) -> String {
        if abs(amount) < 100_000 {
            if let symbol {
                return currencyFormatter.string(decimal: Decimal(amount), symbol: symbol)
            } else {
                return currencyFormatter.string(amount)
            }
        }
        if #available(iOS 18, *) {
            if let symbol {
                let string = amount
                    .formatted(
                        .number
                        .notation(.compactName).locale(locale).precision(.fractionLength(0...2))
                    )
                return "\(string) \(symbol)"
            } else {
                return amount
                    .formatted(
                        .currency(code: currencyFormatter.currencyCode)
                        .notation(.compactName).locale(locale).precision(.fractionLength(0...2))
                    )
            }
        } else {
            return amount.description
        }
    }
}
