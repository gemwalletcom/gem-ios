// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum ChatwootJSEvent: String {
    case ready = "chatwoot:ready"
    case closed = "chatwoot:closed"
}

enum ChatwootHandler: String {
    case chatOpened
}

enum ChatwootMessage: String {
    case ready
    case closed
    case opened
}
