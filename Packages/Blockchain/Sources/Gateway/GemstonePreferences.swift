// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone

public final class GemstonePreferences: GemPreferences, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let namespace: String
    
    public init(
        namespace: String,
        userDefaults: UserDefaults = .standard
    ) {
        self.namespace = namespace
        self.userDefaults = userDefaults
    }
    
    public func get(key: String) throws -> String? {
        return userDefaults.string(forKey: namespace + key)
    }
    
    public func set(key: String, value: String) throws {
        userDefaults.set(value, forKey: namespace + key)
    }
    
    public func remove(key: String) throws {
        userDefaults.removeObject(forKey: namespace + key)
    }
}
