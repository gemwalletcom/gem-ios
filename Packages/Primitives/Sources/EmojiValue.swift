// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI

public struct EmojiValue: Hashable {
    public let emoji: String
    public let color: Color
    
    public init(emoji: String, color: Color) {
        self.emoji = emoji
        self.color = color
    }
}

extension EmojiValue: Identifiable {
    public var id: String { emoji }
}
