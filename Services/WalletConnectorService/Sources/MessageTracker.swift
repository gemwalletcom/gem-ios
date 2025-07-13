// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

actor MessageTracker {
    private var messages = Set<String>()
    
    func shouldProcess(_ messageId: String) -> Bool {
        if messages.contains(messageId) {
            return false
        }
        messages.insert(messageId)
        return true
    }
}
