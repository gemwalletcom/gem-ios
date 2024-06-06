// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

public extension UserDefaults {
    static func mock(
        suiteName: String = UUID().uuidString
    ) -> UserDefaults {
        UserDefaults(suiteName: suiteName)!
    }
}
