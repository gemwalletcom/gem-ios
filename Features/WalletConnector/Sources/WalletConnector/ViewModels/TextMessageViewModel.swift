// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct TextMessageViewModel {
    private let message: String
    
    init(message: String) {
        self.message = message
    }
    
    var text: String {
        message
    }
}
