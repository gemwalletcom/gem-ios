// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keychain

public struct SecureNamespacedPreferences: Sendable {
    private let keychain: Keychain
    private let namespace: String
    
    public init(namespace: String, keychain: Keychain = KeychainDefault()) {
        self.namespace = namespace
        self.keychain = keychain
    }
    
    public func get(_ key: String) throws -> String? {
        try keychain.get("\(namespace)_\(key)")
    }
    
    public func set(_ value: String, key: String) throws {
        try keychain.set(value, key: "\(namespace)_\(key)")
    }
    
    public func remove(_ key: String) throws {
        try keychain.remove("\(namespace)_\(key)")
    }
}