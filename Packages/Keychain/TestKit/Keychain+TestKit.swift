// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keychain
import LocalAuthentication

public struct KeychainMock: Keychain {
    public init() {}
    
    public func accessibility(_ accessibility: Accessibility, authenticationPolicy: AuthenticationPolicy) -> Keychain {
        KeychainMock()
    }
    public func authenticationContext(_ authenticationContext: LAContext) -> Keychain {
        KeychainMock()
    }

    public func get(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> String? {
        nil
    }
    public func getString(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> String?{
        nil
    }
    public func getData(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> Data?{
        nil
    }

    public func set(_ value: String, key: String, ignoringAttributeSynchronizable: Bool) throws {}
    public func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool) throws {}

    public func remove(_ key: String, ignoringAttributeSynchronizable: Bool) throws {}
}
