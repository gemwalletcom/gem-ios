// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import LocalAuthentication

public class MockKeystorePassword: KeystorePassword {
    private var memoryPassword: String
    private var isAuthenticationEnabled: Bool
    private var availableAuthentication: KeystoreAuthentication

    public init(
        memoryPassword: String = "",
        isAuthenticationEnabled: Bool = false,
        availableAuthentication: KeystoreAuthentication = .none
    ) {
        self.memoryPassword = memoryPassword
        self.isAuthenticationEnabled = isAuthenticationEnabled
        self.availableAuthentication = availableAuthentication
    }

    public func setPassword(_ password: String, authentication: KeystoreAuthentication) throws {
        memoryPassword = password
    }
    
    public  func getPassword() throws -> String {
        memoryPassword
    }
    
    public func getAuthentication() throws -> KeystoreAuthentication {
        availableAuthentication
    }
    
    public func getAvailableAuthentication() -> KeystoreAuthentication {
        availableAuthentication
    }

    public func enableAuthentication(_ enable: Bool, context: LAContext) throws {
        isAuthenticationEnabled = enable
    }

    public func remove() throws {
        memoryPassword = ""
    }
}
