// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keychain
import LocalAuthentication

public final class MockKeychain: Keychain, @unchecked Sendable {
    private var storage: [String: Data] = [:]
    
    public init(storage: [String: String] = [:]) {
        self.storage = storage.mapValues { $0.data(using: .utf8)! }
    }
    
    public func accessibility(_ accessibility: Accessibility, authenticationPolicy: AuthenticationPolicy) -> Keychain {
        self
    }
    
    public func authenticationContext(_ authenticationContext: LAContext) -> Keychain {
        self
    }
    
    public func get(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> String? {
        try getString(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    }
    
    public func getString(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> String? {
        guard let data = storage[key] else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func getData(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> Data? {
        storage[key]
    }
    
    public func set(_ value: String, key: String, ignoringAttributeSynchronizable: Bool) throws {
        storage[key] = value.data(using: .utf8)!
    }
    
    public func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool) throws {
        storage[key] = value
    }
    
    public func remove(_ key: String, ignoringAttributeSynchronizable: Bool) throws {
        storage.removeValue(forKey: key)
    }
}
