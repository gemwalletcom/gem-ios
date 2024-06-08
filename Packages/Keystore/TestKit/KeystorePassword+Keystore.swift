// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore

public class MockKeystorePassword: KeystorePassword {
    
    private var memoryPassword: String = ""
    
    public init() {
        
    }
    
    public  func setPassword(_ password: String, authentication: KeystoreAuthentication) throws {
        self.memoryPassword = password
    }
    
    public  func getPassword() throws -> String {
        memoryPassword
    }
    
    public func getAuthentication() throws -> KeystoreAuthentication {
        return .none
    }
    
    public func getAvailableAuthentication() throws -> KeystoreAuthentication {
        return .none
    }
    
    public func remove() throws {
        memoryPassword = ""
    }
}
