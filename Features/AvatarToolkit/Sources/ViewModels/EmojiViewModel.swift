// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Primitives
import Style

@Observable
final class EmojiViewModel {
    init() {}

    var color: Color = .random()
    var text: String = .empty
    
    var emojiColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 5)
    }
    
    var emojiList: [EmojiValue] = {
        Emoji.WalletAvatar.allCases.map { EmojiValue(emoji: $0.rawValue, color: .random()) }
    }()
    
    var colorColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 5)
    }
    
    var colorList: [Color] = {
        (0..<20).map { count in
            .random()
        }
    }()
}
