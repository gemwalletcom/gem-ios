// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import LocalAuthentication

public protocol KeystorePassword: Sendable {
    func setPassword(_ password: String, authentication: KeystoreAuthentication) throws
    func getPassword() throws -> String
    func getAuthentication() throws -> KeystoreAuthentication
    func getAvailableAuthentication() -> KeystoreAuthentication
    func enableAuthentication(_ enable: Bool, context: LAContext) throws
    func remove() throws

    func getPrivacyLockStatus() throws -> PrivacyLockStatus?
    func setPrivacyLockStatus(_ status: PrivacyLockStatus) throws

    func getAuthenticationLockPeriod() throws -> LockPeriod?
    func setAuthenticationLockPeriod(period: LockPeriod) throws
}
