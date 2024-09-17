// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import KeychainAccess
import LocalAuthentication

public protocol KeystorePassword {
    func setPassword(_ password: String, authentication: KeystoreAuthentication) throws
    func getPassword() throws -> String
    func getAuthentication() throws -> KeystoreAuthentication
    func getAvailableAuthentication() -> KeystoreAuthentication
    func enableAuthentication(_ enable: Bool, context: LAContext) throws
    func remove() throws
}
