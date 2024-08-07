// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct Emoji {
    public static let greenCircle = "🟢"
    public static let orangeCircle = "🟠"
    public static let redCircle = "🔴"
    public static let checkmark = "✅"
    public static let reject = "❌"
    public static let rocket = "🚀"
    public static let turle = "🐢"
    public static let gem = "💎"

}

// MARK: - Previews

#Preview {
    let symbols = [
        (Emoji.greenCircle, "Green Circle"),
        (Emoji.orangeCircle, "Orange Circle"),
        (Emoji.redCircle, "Red Circle"),
        (Emoji.checkmark, "Checkmark"),
        (Emoji.reject, "Reject"),
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
