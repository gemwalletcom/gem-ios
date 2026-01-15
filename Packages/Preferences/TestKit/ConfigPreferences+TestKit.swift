// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences

public extension ConfigPreferences {
    static func mock(defaults: UserDefaults = .mock()) -> ConfigPreferences {
        ConfigPreferences(defaults: defaults)
    }
}
