// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import StoreTestKit
import WalletService
import Preferences
import PreferencesTestKit
import Keystore
import KeystoreTestKit
import AvatarService

public extension WalletService {
    static func mock(
        keystore: any Keystore = LocalKeystore.mock(),
        walletStore: WalletStore = .mock(),
        preferences: ObservablePreferences = .mock()
    ) -> WalletService {
        WalletService(
            keystore: keystore,
            walletStore: walletStore,
            preferences: preferences,
            avatarService: AvatarService(store: walletStore)
        )
    }
}
