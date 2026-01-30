// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Keychain

public final class SecurePreferences: Sendable {
    public enum Keys: String, CaseIterable {
        case deviceId
        case deviceToken
        case devicePrivateKey
        case devicePublicKey
    }

    public static let standard = SecurePreferences()

    private let keychain: any KeychainPreferenceStorable
    
    public init(keychain: any KeychainPreferenceStorable = KeychainDefault()) {
        self.keychain = keychain
    }
    
    @discardableResult
    public func set(value: String, key: SecurePreferences.Keys) throws -> String {
        try keychain.set(value: value, key: key.rawValue)
        return value
    }
    
    public func get(key: SecurePreferences.Keys) throws -> String? {
        try keychain.get(key: key.rawValue)
    }
    
    public func delete(key: SecurePreferences.Keys) throws {
        try keychain.remove(key: key.rawValue)
    }

    public func getDeviceId() throws -> String  {
        guard let deviceId = try SecurePreferences.standard.get(key: .deviceId) else {
            throw AnyError("no device id")
        }
        return deviceId
    }

    public func clear() throws {
        for key in Keys.allCases {
            try delete(key: key)
        }
    }
}

extension KeychainDefault: KeychainPreferenceStorable {
    public func set(value: String, key: String) throws {
        try set(value, key: key, ignoringAttributeSynchronizable: true)
    }

    public func get(key: String) throws -> String? {
        try get(key, ignoringAttributeSynchronizable: true)
    }

    public func remove(key: String) throws {
        try remove(key, ignoringAttributeSynchronizable: true)
    }
}
