// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import KeychainAccess
import Primitives

public typealias SecurePreferences = SecurePreferencesStore

public final class SecurePreferencesStore: Sendable {

    public static let standard = SecurePreferencesStore()
    
    let keychain: Keychain
    
    public enum Keys: String, CaseIterable {
        case deviceId
        case deviceToken
    }
    
    public init(
        keychain: Keychain = Keychain()
    ) {
        self.keychain = keychain
    }
    
    @discardableResult
    public func set(key: SecurePreferencesStore.Keys, value: String) throws -> String {
        try keychain.set(value, key: key.rawValue)
        return value
    }
    
    public func get(key: SecurePreferencesStore.Keys) throws -> String? {
        return try keychain.get(key.rawValue)
    }
    
    public func delete(key: SecurePreferencesStore.Keys) throws {
        return try keychain.remove(key.rawValue)
    }
    
    public func clear() throws {
        for key in Keys.allCases {
            try delete(key: key)
        }
    }

    public func getDeviceId() throws -> String  {
        guard let deviceId = try SecurePreferences.standard.get(key: .deviceId) else {
            throw AnyError("no device id")
        }
        return deviceId
    }
}
