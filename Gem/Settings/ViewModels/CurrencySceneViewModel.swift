// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Store

class CurrencySceneViewModel: ObservableObject {

    let preferences: Preferences

    @Published var currency: String {
        didSet {
            preferences.currency = currency
        }
    }

    init(
        preferences: Preferences = .standard
    ) {
        self.currency = preferences.currency
        self.preferences = preferences
    }

    var title: String {
        return Localized.Settings.currency
    }

    var defaultCurrencies: [String] {
        return [
            Currency.usd.rawValue,
            Currency.eur.rawValue,
            Currency.gbp.rawValue,
            Currency.cny.rawValue,
            Currency.jpy.rawValue,
            Currency.inr.rawValue,
            Currency.rub.rawValue,
            currency,
        ]
    }

    var recommendedCurrencies: [Locale.Currency] {
        let values = defaultCurrencies.map {
            Locale.Currency($0)
        }
        return ([Locale.current.currency] + values).compactMap { $0 }.unique()
    }

    var list: [ListItemValueSection<String>] {
        return [
            ListItemValueSection(
                section: Localized.Common.recommended,
                values: recommendedCurrencies.map {
                    ListItemValue(title: $0.title, value: $0.identifier)
                }
            ),
            ListItemValueSection(
                section: Localized.Common.all,
                values: Currency.nativeCurrencies.map {
                    ListItemValue(title: $0.title, value: $0.identifier)
                }
            )
        ]
    }
}

extension Locale.Currency {
    var title: String {
        return String(format: "%@ %@ - %@", emojiFlag, identifier, Locale.current.localizedString(forCurrencyCode: identifier) ?? .empty)
    }

    static private let emojiFlags: [String: String] = [
        "MXN": "🇲🇽",
        "CHF": "🇨🇭",
        "CNY": "🇨🇳",
        "THB": "🇹🇭",
        "HUF": "🇭🇺",
        "AUD": "🇦🇺",
        "IDR": "🇮🇩",
        "RUB": "🇷🇺",
        "ZAR": "🇿🇦",
        "EUR": "🇪🇺",
        "NZD": "🇳🇿",
        "SAR": "🇸🇦",
        "SGD": "🇸🇬",
        "BMD": "🇧🇲",
        "KWD": "🇰🇼",
        "HKD": "🇭🇰",
        "JPY": "🇯🇵",
        "GBP": "🇬🇧",
        "DKK": "🇩🇰",
        "KRW": "🇰🇷",
        "PHP": "🇵🇭",
        "CLP": "🇨🇱",
        "TWD": "🇹🇼",
        "PKR": "🇵🇰",
        "BRL": "🇧🇷",
        "CAD": "🇨🇦",
        "BHD": "🇧🇭",
        "MMK": "🇲🇲",
        "VEF": "🇻🇪",
        "VND": "🇻🇳",
        "CZK": "🇨🇿",
        "TRY": "🇹🇷",
        "INR": "🇮🇳",
        "ARS": "🇦🇷",
        "BDT": "🇧🇩",
        "NOK": "🇳🇴",
        "USD": "🇺🇸",
        "LKR": "🇱🇰",
        "ILS": "🇮🇱",
        "PLN": "🇵🇱",
        "NGN": "🇳🇬",
        "UAH": "🇺🇦",
        "XDR": "🏳️",
        "MYR": "🇲🇾",
        "AED": "🇦🇪",
        "SEK": "🇸🇪"
    ]

    private var emojiFlag: String {
        return Locale.Currency.emojiFlags[self.identifier] ?? ""
    }
}
