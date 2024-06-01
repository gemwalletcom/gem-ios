// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import KeychainAccess

public protocol KeystorePassword {
    func setPassword(_ password: String, authentication: KeystoreAuthentication) throws
    func getPassword() throws -> String
    func getAuthentication() throws -> KeystoreAuthentication
    func getAvailableAuthentication() throws -> KeystoreAuthentication
    func remove() throws
}
