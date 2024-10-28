// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension Preferences {
    static func mock(
        defaults: UserDefaults = .mock()
    ) -> Preferences {
        Preferences(defaults: defaults)
    }
}
