// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import LocalAuthentication

public protocol Keychain: Sendable {
    func accessibility(_ accessibility: Accessibility, authenticationPolicy: AuthenticationPolicy) -> Keychain
    func authenticationContext(_ authenticationContext: LAContext) -> Keychain

    func get(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> String?
    func getString(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> String?
    func getData(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> Data?

    func set(_ value: String, key: String, ignoringAttributeSynchronizable: Bool) throws
    func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool) throws

    func remove(_ key: String, ignoringAttributeSynchronizable: Bool) throws
}

public extension Keychain {
    func get(_ key: String) throws -> String? {
        try get(key, ignoringAttributeSynchronizable: true)
    }

    func getString(_ key: String) throws -> String? {
        try getString(key, ignoringAttributeSynchronizable: true)
    }

    func getData(_ key: String) throws -> Data? {
        try getData(key, ignoringAttributeSynchronizable: true)
    }

    func set(_ value: String, key: String) throws {
        try set(value, key: key, ignoringAttributeSynchronizable: true)
    }

    func set(_ value: Data, key: String) throws {
        try set(value, key: key, ignoringAttributeSynchronizable: true)
    }

    func remove(_ key: String) throws {
        try remove(key, ignoringAttributeSynchronizable: true)
    }
}
