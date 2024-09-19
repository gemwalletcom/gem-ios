// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import LocalAuthentication

public protocol BiometryAuthenticatable {
    var isAuthenticationEnabled: Bool { get }
    var availableAuthentication: KeystoreAuthentication { get }
    var lockPeriod: LockPeriod? { get }

    func authenticate(context: LAContext, reason: String) async throws
    func enableAuthentication(_ enable: Bool, context: LAContext, reason: String) async throws
    func update(period: LockPeriod) throws
}

extension BiometryAuthenticatable {
    public func authenticate(reason: String) async throws {
        try await authenticate(context: LAContext(), reason: reason)
    }

    public func enableAuthentication(_ enable: Bool, reason: String) async throws {
        try await enableAuthentication(enable, context: LAContext(), reason: reason)
    }
}
