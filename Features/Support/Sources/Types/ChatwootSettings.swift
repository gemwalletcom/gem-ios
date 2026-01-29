// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct ChatwootSettings: Sendable {
    enum DarkMode: String, Sendable {
        case auto
        case light
        case dark
    }
    
    let hideMessageBubble: Bool
    let locale: Locale
    let darkMode: DarkMode
    let enableEmojiPicker: Bool
    let enableEndConversation: Bool
    
    init(
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

extension ChatwootSettings {
    static let defaultSettings = ChatwootSettings(
        hideMessageBubble: true,
        locale: .current,
        darkMode: .auto,
        enableEmojiPicker: false,
        enableEndConversation: false
    )
}
