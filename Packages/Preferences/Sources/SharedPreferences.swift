// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct SharedPreferences {
    private let userDefaults: UserDefaults?
    
    public init(
        userDefaults: UserDefaults? = UserDefaults(suiteName: Preferences.Constants.appGroupIdentifier)
    ) {
        self.userDefaults = userDefaults
    }
    
    public var currency: String {
        get {
            userDefaults?.string(forKey: Preferences.Keys.currency) ?? Currency.usd.rawValue
        }
        set {
            userDefaults?.set(newValue, forKey: Preferences.Keys.currency)
            userDefaults?.synchronize()
        }
    }
}