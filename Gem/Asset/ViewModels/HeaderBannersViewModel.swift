// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct HeaderBannersViewModel {
    let banners: [Banner]
    
    var isButtonsEnabled: Bool {
        if banners.map({ $0.event }).contains(.accountBlockedMultiSignature) {
            return false
        }
        return true
    }
}
