// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Primitives
import Style

@Observable
final class EmojiViewModel {
    var color: Color = Colors.listStyleColor
    var text: String = .empty
    var emojiList: [EmojiValue]
    var colorList: [Color]
    
    init() {
        emojiList = Self.shuffleList()
        colorList = Self.shuffleColorList()
    }

    var emojiColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 5)
    }
    
    var colorColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 5)
    }
    
    static func shuffleList() -> [EmojiValue] {
        Array(
            Emoji
                .WalletAvatar
                .allCases
                .shuffled()
                .map { EmojiValue(emoji: $0.rawValue, color: Colors.listStyleColor) }
                .prefix(20)
        )
    }
    
    static func shuffleColorList() -> [Color] {
        (0..<20).map { count in
            .random()
        }
    }
}
