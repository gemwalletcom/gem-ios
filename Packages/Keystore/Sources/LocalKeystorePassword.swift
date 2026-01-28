// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keychain
import LocalAuthentication
import Primitives

public final class LocalKeystorePassword: KeystorePassword {
    private struct Keys {
        static let password = "password"
        static let passwordAuthentication = "password_authentication"
        static let passwordAuthenticationPeriod = "password_authentication_period"
        static let passwordAuthenticationPrivacyLock = "password_authentication_privacy_lock"
    }
    
    private let keychain: Keychain = KeychainDefault()
    
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

    public func getAuthenticationLockPeriod() throws -> LockPeriod? {
        guard let option = try keychain.get(Keys.passwordAuthenticationPeriod) else {
            return .none
        }
        return LockPeriod(rawValue: option)
    }

    public func getPrivacyLockStatus() throws -> PrivacyLockStatus? {
        guard let value = try keychain.get(Keys.passwordAuthenticationPrivacyLock) else {
            return .none
        }
        return PrivacyLockStatus(rawValue: value) ?? .none
    }

    public func setPrivacyLockStatus(_ status: PrivacyLockStatus) throws {
        try keychain.set(status.rawValue, key: Keys.passwordAuthenticationPrivacyLock)
    }

    public func setAuthenticationLockPeriod(period: LockPeriod) throws {
        try keychain.set(period.rawValue, key: Keys.passwordAuthenticationPeriod)
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
            try setPrivacyLockStatus(.disabled)
            try setAuthenticationLockPeriod(period: .default)
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
        try keychain.remove(Keys.password)
        try keychain.remove(Keys.passwordAuthentication)
        try keychain.remove(Keys.passwordAuthenticationPeriod)
        try keychain.remove(Keys.passwordAuthenticationPrivacyLock)
    }
}

// MARK: - Private

extension LocalKeystorePassword {
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
    func canEvaluatePolicyThrowing(policy: LAPolicy) throws {
        var error : NSError?
        canEvaluatePolicy(policy, error: &error)
        if let error = error { throw error }
    }
}
