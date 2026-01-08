// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences
import Primitives

public extension WalletPreferences {
    static func mock(walletId: WalletId = WalletId(id: UUID().uuidString)) -> WalletPreferences {
        WalletPreferences(walletId: walletId)
    }
}
