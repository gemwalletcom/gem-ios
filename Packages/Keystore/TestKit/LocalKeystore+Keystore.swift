// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Store

public extension LocalKeystore {
    static func mock(
        preferences: Preferences = Preferences(),
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
