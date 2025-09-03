// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Keychain

public final class GemstoneSecurePreferences: GemPreferences, @unchecked Sendable {
    private let keychain: Keychain
    private let namespace: String
    
    public init(
        namespace: String,
        keychain: Keychain = KeychainDefault()
    ) {
        self.namespace = namespace
        self.keychain = keychain
    }
    
    public func get(key: String) throws -> String? {
        return try keychain.get(namespace + key)
    }
    
    public func set(key: String, value: String) throws {
        try keychain.set(value, key: namespace + key)
    }
    
    public func remove(key: String) throws {
        try keychain.remove(namespace + key)
    }
}
