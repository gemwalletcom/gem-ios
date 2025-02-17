// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Style

struct EmojiView: View {
    var color: Color
    var emoji: String

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(color)
                
                Text(emoji)
                    .font(.system(size: geometry.size.width * 0.65))
                    .minimumScaleFactor(0.01)
                    .multilineTextAlignment(.center)
                    .scaledToFit()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    EmojiView(color: .red, emoji: Emoji.WalletAvatar.firework.rawValue)
        .frame(width: 100, height: 100)
}
