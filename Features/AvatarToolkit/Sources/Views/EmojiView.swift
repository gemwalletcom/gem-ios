// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Style

struct EmojiView: View {
    var color: Color
    var emoji: String

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
            
            Text(emoji)
                .padding(Spacing.medium)
                .font(.system(size: 150))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.01)
        }
    }
}
