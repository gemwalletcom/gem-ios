// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Primitives
import Style

@Observable
public final class EmojiStyleViewModel {
    var color: Color = Colors.listStyleColor
    var text: String = .empty
    let emojiList: [EmojiValue]
    var colorList: [Color]
    let emojiColumns: [GridItem]
    let colorColumns: [GridItem]
    
    let onDone: (EmojiValue) -> Void
    
    init(onDone: @escaping (EmojiValue) -> Void) {
        self.onDone = onDone
        emojiList = Self.shuffleList()
        colorList = Self.shuffleColorList()
        emojiColumns = Self.createColumns()
        colorColumns = Self.createColumns()
    }
    
    func setRandomEmoji() {
        text = Self.shuffleList().first?.emoji ?? .empty
    }
    
    func onDoneEmojiValue() {
        onDone(EmojiValue(emoji: text, color: color))
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
    
    static func createColumns() -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.medium), count: 5)
    }
}
