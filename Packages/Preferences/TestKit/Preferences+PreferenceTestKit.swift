// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences

public extension Preferences {
    static func mock(defaults: UserDefaults = .mock()) -> Preferences {
        Preferences(defaults: defaults)
    }
}
