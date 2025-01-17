// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences

public extension SecurePreferences {
    static func mock(
        keychain: any KeychainPreferenceStorable = MockKeychainPreference.mock()
    ) -> SecurePreferences {
        SecurePreferences(keychain: keychain)
    }
}

