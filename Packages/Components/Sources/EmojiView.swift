// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Style

public struct EmojiView: View {
    public let color: Color
    public let emoji: String
    
    public init(color: Color, emoji: String) {
        self.color = color
        self.emoji = emoji
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(color)
                
                Text(emoji)
                    .font(.system(size: geometry.size.width * 0.6))
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
