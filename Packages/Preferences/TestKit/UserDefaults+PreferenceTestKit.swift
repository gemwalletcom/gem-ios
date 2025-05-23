// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension UserDefaults {
    static func mock(suiteName: String = UUID().uuidString) -> UserDefaults {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    static func mockWithValues(suiteName: String = UUID().uuidString, values: [String: Any]) -> UserDefaults {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        values.forEach { key, value in
            defaults.setValue(value, forKey: key)
        }
        return defaults
    }
}
