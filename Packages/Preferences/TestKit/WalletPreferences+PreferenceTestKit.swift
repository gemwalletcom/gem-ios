// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences

public extension WalletPreferences {
    static func mock(walletId: String = UUID().uuidString) -> WalletPreferences {
        WalletPreferences(walletId: walletId)
    }
}
