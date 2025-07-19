// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import PreferencesTestKit
@testable import Preferences

struct ConfigurableDefaultsTests {
    
    @Test
    func standardBehavior() {
        let defaults = UserDefaults.mock()
        var config = ConfigurableDefaults(key: "key", defaultValue: "default", defaults: defaults)
        
        #expect(config.wrappedValue == "default")
        
        config.wrappedValue = "new"
        #expect(config.wrappedValue == "new")
        #expect(defaults.string(forKey: "key") == "new")
    }
    
    @Test
    func sharedDefaultsSyncing() {
        let defaults = UserDefaults.mock()
        let shared = UserDefaults.mock()
        var config = ConfigurableDefaults(key: "key", defaultValue: "value", defaults: defaults, sharedDefaults: shared)
        
        config.wrappedValue = "synced"
        
        #expect(defaults.string(forKey: "key") == "synced")
        #expect(shared.string(forKey: "key") == "synced")
    }
}