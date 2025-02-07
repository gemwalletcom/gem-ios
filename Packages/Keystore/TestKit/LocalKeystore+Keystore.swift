// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Preferences
import Store
import PreferencesTestKit

public extension LocalKeystore {
    static let words = ["shoot", "island", "position", "soft", "burden", "budget", "tooth", "cruel", "issue", "economy", "destroy", "above"]

    static func mock(
        preferences: Preferences = Preferences.mock(),
        keystorePassword: KeystorePassword = MockKeystorePassword()
    ) -> LocalKeystore {
        let id = NSUUID().uuidString
        return LocalKeystore(
            folder: id,
            walletStore: WalletStore(db: DB(path: "\(id).sqlite")),
            preferences: preferences,
            keystorePassword: keystorePassword
        )
    }
}
