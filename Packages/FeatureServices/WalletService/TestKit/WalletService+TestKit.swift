// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StoreTestKit
import KeystoreTestKit
import PreferencesTestKit
import WalletService
import Store
import Keystore
import Preferences
import AvatarService

public extension WalletService {
    static func mock(
        keystore: any Keystore = LocalKeystore.mock(),
        walletStore: WalletStore = .mock(),
        preferences: ObservablePreferences = .mock(),
        avatarService: AvatarService = AvatarService(store: .mock())
    ) -> WalletService {
        WalletService(
            keystore: keystore,
            walletStore: walletStore,
            preferences: preferences,
            avatarService: avatarService
        )
    }
}
