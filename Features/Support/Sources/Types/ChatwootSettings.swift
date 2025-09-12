// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ChatwootSettings: Sendable {
    public enum DarkMode: String, Sendable {
        case auto
        case light
        case dark
    }
    
    let hideMessageBubble: Bool
    let locale: Locale
    let darkMode: DarkMode
    let enableEmojiPicker: Bool
    let enableEndConversation: Bool
    
    public init(
        hideMessageBubble: Bool,
        locale: Locale,
        darkMode: DarkMode,
        enableEmojiPicker: Bool,
        enableEndConversation: Bool
    ) {
        self.hideMessageBubble = hideMessageBubble
        self.locale = locale
        self.darkMode = darkMode
        self.enableEmojiPicker = enableEmojiPicker
        self.enableEndConversation = enableEndConversation
    }
}

public extension ChatwootSettings {
    static let defaultSettings = ChatwootSettings(
        hideMessageBubble: true,
        locale: .current,
        darkMode: .auto,
        enableEmojiPicker: false,
        enableEndConversation: false
    )
}
