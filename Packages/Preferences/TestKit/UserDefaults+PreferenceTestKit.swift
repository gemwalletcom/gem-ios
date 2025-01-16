// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension UserDefaults {
    static func mock(suiteName: String = UUID().uuidString) -> UserDefaults {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
