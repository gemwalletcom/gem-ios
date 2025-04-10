// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Preferences
import Store
import PreferencesTestKit
import StoreTestKit

public extension LocalKeystore {
    static let words = ["shoot", "island", "position", "soft", "burden", "budget", "tooth", "cruel", "issue", "economy", "destroy", "above"]

    static func mock(
        walletStore: WalletStore = .mock(), 
        preferences: ObservablePreferences = ObservablePreferences.mock(),
        keystorePassword: KeystorePassword = MockKeystorePassword()
    ) -> LocalKeystore {
        LocalKeystore(
            folder: NSUUID().uuidString,
            walletStore: walletStore,
            preferences: preferences,
            keystorePassword: keystorePassword
        )
    }
}
