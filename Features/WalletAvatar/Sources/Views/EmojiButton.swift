// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Style

struct EmojiButton: View {
    let color: Color
    let emoji: String
    let action: VoidAction
    
    var body: some View {
        GeometryReader(content: { geometry in
            Button(action: {
                withAnimation {
                    action?()
                }
            }) {
                EmojiView(color: color, emoji: emoji)
            }
        })
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    EmojiButton(color: .red, emoji: Emoji.WalletAvatar.gem.rawValue, action: { })
        .frame(width: 50, height: 50)
}
