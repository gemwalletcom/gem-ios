// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import KeychainAccess
import LocalAuthentication
import Primitives

public class LocalKeystorePassword: KeystorePassword {
    private struct Keys {
        static let password = "password"
        static let passwordAuthentication = "password_authentication"
    }
    
    private let keychain = Keychain()
    
    public init() {}
    
    public func getAvailableAuthentication() -> KeystoreAuthentication {
        KeystoreAuthentication.availableAuthenticationType
    }
    
    public func getAuthentication() throws -> KeystoreAuthentication {
        guard let value = try keychain.get(Keys.passwordAuthentication) else {
            return .none
        }
        return KeystoreAuthentication(rawValue: value) ?? .none
    }
    
    public func enableAuthentication(_ enable: Bool, context: LAContext) throws {
        switch enable {
        case true:
            let authentication = getAvailableAuthentication()
            switch authentication {
            case .biometrics, .passcode:
                try changeAuthentication(authentication: authentication, context: context)
            case .none:
                throw AnyError("No authentication available")
            }
        case false:
            try changeAuthentication(authentication: .none, context: context)
        }
    }
    
    public func getPassword() throws -> String {
        try getPassword(context: LAContext())
    }
    
    public func getPassword(context: LAContext) throws -> String {
        try keychain
            .authenticationContext(context)
            .get(Keys.password) ?? ""
    }
    
    public func setPassword(_ password: String, authentication: KeystoreAuthentication) throws {
        try setPassword(password, authentication: authentication, context: LAContext())
    }
    
    public func remove() throws {
        try keychain
            .remove(Keys.password)
    }
    
    private func setPassword(
        _ password: String,
        authentication: KeystoreAuthentication,
        context: LAContext
    ) throws {
        try keychain
            .set(authentication.rawValue, key: Keys.passwordAuthentication)
        
        try keychain
            .accessibility(.whenUnlockedThisDeviceOnly, authenticationPolicy: authentication.policy)
            .authenticationContext(context)
            .set(password, key: Keys.password)
    }
    
    private func changeAuthentication(authentication: KeystoreAuthentication, context: LAContext) throws {
        let password = try getPassword(context: context)
        try setPassword(password, authentication: authentication, context: context)
    }
}

// MARK: - Models extensions

extension LAContext {
    public func canEvaluatePolicyThrowing(policy: LAPolicy) throws {
        var error : NSError?
        canEvaluatePolicy(policy, error: &error)
        if let error = error { throw error }
    }
}
