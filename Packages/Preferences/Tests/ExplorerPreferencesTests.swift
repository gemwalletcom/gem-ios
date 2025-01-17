// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PreferencesTestKit
import Primitives

@testable import Preferences

struct ExplorerPreferencesTests {
    private let preferences: any ExplorerPreferencesStorable = ExplorerPreferences.mock()

    @Test
    func testDefaultPreferences() {
        #expect(preferences.get(chain: .bitcoin) == nil)
    }

    @Test
    func testUpdatePreferences() {
        #expect(preferences.get(chain: .bitcoin) == nil)
        preferences.set(chain: .bitcoin, name: "some name")
        #expect(preferences.get(chain: .bitcoin) == "some name")
    }
}
