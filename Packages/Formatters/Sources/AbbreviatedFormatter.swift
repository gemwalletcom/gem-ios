// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct AbbreviatedFormatter: Sendable {
    private let locale: Locale
    private let threshold: Decimal

    init(
        locale: Locale = .current,
        threshold: Decimal = 100_000
    ) {
        self.locale = locale
        self.threshold = threshold
    }

    func string(from double: Double) -> String? {
        string(from: Decimal(double))
    }

    func string(from double: Double, currency: String) -> String? {
        string(from: Decimal(double), currency: currency)
    }

    func string(from decimal: Decimal) -> String? {
        guard abs(decimal) >= threshold, #available(iOS 18, *) else {
            return nil
        }
        
        return decimal.formatted(
            .number
            .notation(.compactName)
            .locale(locale)
            .precision(.fractionLength(0...2))
        )
    }
    
    func string(from decimal: Decimal, currency: String) -> String? {
        guard abs(decimal) >= threshold, #available(iOS 18, *) else {
            return nil
        }
        
        return decimal.formatted(
            .currency(code: currency)
            .notation(.compactName)
            .locale(locale)
            .precision(.fractionLength(0...2))
        )
    }
}
