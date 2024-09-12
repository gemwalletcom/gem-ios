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
    
    let keychain = Keychain()
    
    public init() {

    }
    
    public func setPassword(_ password: String, authentication: KeystoreAuthentication) throws {
        return try setPassword(password, authentication: authentication, context: LAContext())
    }
    
    public func getPassword() throws -> String {
        return try getPassword(context: LAContext())
    }
    
    public func setPassword(
        _ password: String,
        authentication: KeystoreAuthentication,
        context: LAContext
    ) throws {
        //NSLog("setPassword")
        try keychain
            .set(authentication.rawValue, key: Keys.passwordAuthentication)
        
        //Changing whenPasscodeSetThisDeviceOnly => whenUnlockedThisDeviceOnly due to Apple Review team not being able to test the app.
        try keychain
            .accessibility(.whenUnlockedThisDeviceOnly, authenticationPolicy: authentication.policy)
            .authenticationContext(context)
            .set(password, key: Keys.password)
    }
    
    public func getPassword(
        context: LAContext
    ) throws -> String {
        //NSLog("getPassword")
        
        return try keychain
            .authenticationContext(context)
            .get(Keys.password) ?? ""
    }
    
    public func getAuthentication() throws -> KeystoreAuthentication {
        //NSLog("getAuthentication")
        guard let value = try keychain.get(Keys.passwordAuthentication) else {
            return .none
        }
        return KeystoreAuthentication(rawValue: value) ?? .none
    }
    
    public func getAvailableAuthentication() throws -> KeystoreAuthentication {
        return KeystoreAuthentication.availableAuthenticationType
    }
    
    public func enableAuthentication(_ value: Bool, context: LAContext) throws {
        switch value {
        case true:
            let authentication = try getAvailableAuthentication()
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
    
    public func changeAuthentication(authentication: KeystoreAuthentication, context: LAContext) throws {
        //NSLog("changeAuthentication \(authentication)")
        
        let password = try getPassword(context: context)
        try setPassword(password, authentication: authentication, context: context)
    }
    
    public func remove() throws {
        try keychain
            .remove(Keys.password)
    }
}

extension LAContext {
    public func canEvaluatePolicyThrowing(policy: LAPolicy) throws {
        var error : NSError?
        canEvaluatePolicy(policy, error: &error)
        if let error = error { throw error }
    }
}
