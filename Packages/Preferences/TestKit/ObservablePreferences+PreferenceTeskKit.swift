// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences

public extension ObservablePreferences {
    static func mock(preferences: Preferences = .mock()) -> ObservablePreferences {
        ObservablePreferences(preferences: preferences)
    }
}
