// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Currency {
    public static var nativeCurrencies: [Locale.Currency] {
        return  Locale.Currency.isoCurrencies.filter {
            if let currency = Currency(rawValue: $0.identifier) {
                return Currency.allCases.contains(currency)
            }
            return false
        }
    }
}
