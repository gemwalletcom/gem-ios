// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Security
import LocalAuthentication

// Adapted from: https://github.com/kishikawakatsumi/KeychainAccess/blob/master/Lib/KeychainAccess/Keychain.swift

public final class KeychainDefault: Keychain {
    fileprivate let options: Options

    // MARK: - Constructors

    public convenience init() {
        var options = Options()
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            options.service = bundleIdentifier
        }
        self.init(options)
    }

    fileprivate init(_ opts: Options) {
        options = opts
    }

    // MARK: - Public (Set Options) methods

    public func accessibility(_ accessibility: Accessibility, authenticationPolicy: AuthenticationPolicy) -> Keychain {
        var options = self.options
        options.accessibility = accessibility
        options.authenticationPolicy = authenticationPolicy
        return KeychainDefault(options)
    }

    public func authenticationContext(_ authenticationContext: LAContext) -> Keychain {
        var options = self.options
        options.authenticationContext = authenticationContext
        return KeychainDefault(options)
    }

    // MARK: - Public (get) methods

    public func get(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws -> String? {
        try getString(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    }

    public func getString(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws -> String? {
        guard let data = try getData(key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable) else  {
            return nil
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw Status.conversionError
        }
        return string
    }

    public func getData(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws -> Data? {
        var query = options.query(ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)

        query[MatchLimit] = MatchLimitOne
        query[ReturnData] = kCFBooleanTrue

        query[AttributeAccount] = key

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw Status.unexpectedError
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw securityError(status: status)
        }
    }

    // MARK: - Public (set) methods

    public func set(_ value: String, key: String, ignoringAttributeSynchronizable: Bool = true) throws {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
            throw Status.conversionError
        }
        try set(data, key: key, ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
    }

    public func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool = true) throws {
        var query = options.query(ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
        query[AttributeAccount] = key
        
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess, errSecInteractionNotAllowed:
            var query = options.query()
            query[AttributeAccount] = key
            
            var (attributes, error) = options.attributes(key: nil, value: value)
            if let error = error {
                throw error
            }
            
            options.attributes.forEach { attributes.updateValue($1, forKey: $0) }
            
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if status != errSecSuccess {
                throw securityError(status: status)
            }
        case errSecItemNotFound:
            var (attributes, error) = options.attributes(key: key, value: value)
            if let error = error {
                throw error
            }
            
            options.attributes.forEach { attributes.updateValue($1, forKey: $0) }
            
            status = SecItemAdd(attributes as CFDictionary, nil)
            if status != errSecSuccess {
                throw securityError(status: status)
            }
        default:
            throw securityError(status: status)
        }
    }

    // MARK: - Public (remove) methods

    public func remove(_ key: String, ignoringAttributeSynchronizable: Bool = true) throws {
        var query = options.query(ignoringAttributeSynchronizable: ignoringAttributeSynchronizable)
        query[AttributeAccount] = key

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw securityError(status: status)
        }
    }

    // MARK: - Error methods

    @discardableResult
    fileprivate class func securityError(status: OSStatus) -> Error {
        Status(status: status)
    }

    @discardableResult
    fileprivate func securityError(status: OSStatus) -> Error {
        type(of: self).securityError(status: status)
    }
}
