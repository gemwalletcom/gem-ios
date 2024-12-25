// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import LocalAuthentication

public final class MockKeystorePassword: KeystorePassword, @unchecked Sendable {
    private var memoryPassword: String
    private var isAuthenticationEnabled: Bool
    private var lockPeriod: LockPeriod?
    private var availableAuthentication: KeystoreAuthentication
    private var privacyLockStatus: PrivacyLockStatus?

    public init(
        memoryPassword: String = "",
        isAuthenticationEnabled: Bool = false,
        lockPeriod: LockPeriod? = .oneMinute,
        availableAuthentication: KeystoreAuthentication = .none,
        privacyLockStatus: PrivacyLockStatus? = .none
    ) {
        self.memoryPassword = memoryPassword
        self.isAuthenticationEnabled = isAuthenticationEnabled
        self.availableAuthentication = availableAuthentication
        self.privacyLockStatus = privacyLockStatus
        self.lockPeriod = lockPeriod
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

    public func getAuthenticationLockPeriod() throws -> LockPeriod? {
        lockPeriod
    }

    public func setAuthenticationLockPeriod(period: LockPeriod) throws {
        lockPeriod = period
    }

    public func enableAuthentication(_ enable: Bool, context: LAContext) throws {
        isAuthenticationEnabled = enable
    }

    public func getPrivacyLockStatus() throws -> PrivacyLockStatus? {
        privacyLockStatus
    }

    public func setPrivacyLockStatus(_ status: PrivacyLockStatus) {
        privacyLockStatus = status
    }

    public func remove() throws {
        memoryPassword = ""
    }
}
