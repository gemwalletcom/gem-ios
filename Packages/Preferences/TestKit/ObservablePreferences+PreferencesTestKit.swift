// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences

public extension ObservablePreferences {
    static func mock(
        preferences: Preferences = .mock(),
        isPerpetualEnabled: Bool = true
    ) -> ObservablePreferences {
        var prefs = preferences
        prefs.isPerpetualEnabled = isPerpetualEnabled
        return ObservablePreferences(preferences: prefs)
    }
}
