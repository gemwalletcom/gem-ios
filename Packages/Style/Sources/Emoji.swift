// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct Emoji {
    public static let greenCircle = "🟢"
    public static let orangeCircle = "🟠"
    public static let redCircle = "🔴"
    public static let checkmark = "✅"
    public static let reject = "❌"
    public static let random = "🎲"
    public static let rocket = "🚀"
    public static let turle = "🐢"
    public static let gem = "💎"

    public struct Flags {
        public static let flagsByIdentifier: [String: String] = [
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
    }
}

// MARK: - Previews

#Preview {
    let symbols = [
        (Emoji.greenCircle, "Green Circle"),
        (Emoji.orangeCircle, "Orange Circle"),
        (Emoji.redCircle, "Red Circle"),
        (Emoji.checkmark, "Checkmark"),
        (Emoji.reject, "Reject"),
        (Emoji.random, "Random"),
        (Emoji.rocket, "Rocket"),
        (Emoji.turle, "Turle"),
        (Emoji.gem, "Gem"),
    ]

    return List {
        ForEach(symbols, id: \.1) { symbol in
            Section(header: Text(symbol.1)) {
                Text(symbol.0)
                    .frame(width: Sizing.list.image, height: Sizing.list.image)
                    .padding(Spacing.extraSmall)
            }
        }
    }
    .listStyle(InsetGroupedListStyle())
    .padding()
}
