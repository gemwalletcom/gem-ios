// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StoreTestKit
import WalletSessionService
import PreferencesTestKit
import Store
import Preferences

public extension WalletSessionService {
    static func mock(
        store: WalletStore = .mock(),
        preferences: ObservablePreferences = .mock()
    ) -> any WalletSessionManageable {
        WalletSessionService(
            walletStore: store,
            preferences: preferences
        )
    }
}
