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
    public static let policeOfficer = "👮‍♂️"

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
    
    public enum WalletAvatar: String, CaseIterable {
        case gem = "💎"
        case unicorn = "🦄"
        case rocket = "🚀"
        case heart = "❤️"
        case heartEyes = "😍"
        case fire = "🔥"
        case poo = "💩"
        case crying = "😭"
        case trophy = "🏆"
        case pirateFlag = "🏴‍☠️"
        case check = "✅"
        case warning = "⚠️"
        case moneyBag = "💰"
        case gift = "🎁"
        case balloon = "🎈"
        case rainbow = "🌈"
        case star = "⭐️"
        case crown = "👑"
        case brokenHeart = "💔"
        case lock = "🔒"
        case bank = "🏦"
        case ninja = "🥷"
        case hacker = "👨‍💻"
        case vault = "🛢"
        case keyEmoji = "🔑"
        case shield = "🛡"
        case upChart = "📈"
        case downChart = "📉"
        case explosion = "💥"
        case alien = "👽"
        case crystalBall = "🔮"
        case zap = "⚡️"
        case globe = "🌍"
        case hourglass = "⏳"
        case robot = "🤖"
        case satellite = "🛰"
        case dragon = "🐉"
        case octopus = "🐙"
        case phoenix = "🦅"
        case eyes = "👀"
        case flex = "💪"
        case crystal = "🔷"
        case ghost = "👻"
        case tornado = "🌪"
        case sunglasses = "🕶"
        case alienHead = "👾"
        case detective = "🕵️‍♂️"
        case hourglassDone = "⌛️"
        case magic = "✨"
        case clover = "🍀"
        case skullAndCrossbones = "☠️"
        case skull = "💀"
        case spiderWeb = "🕸"
        case spider = "🕷"
        case slotMachine = "🎰"
        case comet = "☄️"
        case mountain = "🏔"
        case desert = "🏜"
        case oceanWave = "🌊"
        case firework = "🎆"
        case medal = "🎖"
        case telescope = "🔭"
        case fuelPump = "⛽️"
        case factory = "🏭"
        case bridge = "🌉"
        case castle = "🏰"
        case hammer = "🔨"
        case toolbox = "🧰"
        case briefcase = "💼"
        case barcode = "🏷"
        case chessPiece = "♟"
        case anchor = "⚓️"
        case ferrisWheel = "🎡"
        case rollerCoaster = "🎢"
        case pumpkin = "🎃"
        case package = "📦"
    }
    
    public enum FeeRate: String {
        case slow = "⏱️"
        case normal = "💎"
        case fast = "⚡️"
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
                    .frame(width: .list.image, height: .list.image)
                    .padding(.extraSmall)
            }
        }
    }
    .listStyle(InsetGroupedListStyle())
    .padding()
}
