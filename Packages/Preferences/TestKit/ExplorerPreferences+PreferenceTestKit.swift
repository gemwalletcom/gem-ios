// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences
import Primitives

public extension ExplorerPreferences {
    static func mock(preferences: Preferences = .mock()) -> any ExplorerPreferencesStorable {
        ExplorerPreferences(preferences: preferences)
    }
}
