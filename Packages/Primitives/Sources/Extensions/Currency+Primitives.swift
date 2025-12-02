// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Currency {
    public static let `default`: Currency = .usd

    public init(id: String) throws {
        if let currency = Currency(rawValue: id) {
            self = currency
        } else {
            throw AnyError("invalid currency: \(id)")
        }
    }
    
    public static var nativeCurrencies: [Locale.Currency] {
        return Locale.Currency.isoCurrencies.filter {
            if let currency = Currency(rawValue: $0.identifier) {
                return Currency.allCases.contains(currency)
            }
            return false
        }
    }
}

extension Currency: Identifiable {
    public var id: String { rawValue }
}
