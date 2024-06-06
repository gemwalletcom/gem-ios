// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension PreferencesStore {
    static func mock(
        defaults: UserDefaults = .mock()
    ) -> PreferencesStore {
        PreferencesStore(defaults: defaults)
    }
}
