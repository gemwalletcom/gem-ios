// Copyright (c). Gem Wallet. All rights reserved.

import LocalAuthentication

public struct BiometryAuthenticationService: BiometryAuthenticable {
    private let keystorePassword: KeystorePassword

    public init(keystorePassword: KeystorePassword = LocalKeystorePassword()) {
        self.keystorePassword = keystorePassword
    }

    public var isAuthenticationEnabled: Bool {
        do {
            return try keystorePassword.getAuthentication() != .none
        } catch {
            return false
        }
    }

    public var availableAuthentication: KeystoreAuthentication {
        keystorePassword.getAvailableAuthentication()
    }

    public func enableAuthentication(_ enable: Bool, context: LAContext, reason: String) async throws {
        try await authenticate(context: context, reason: reason)
        try keystorePassword.enableAuthentication(enable, context: context)
    }

    public func authenticate(context: LAContext, reason: String) async throws {
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch let error as NSError {
            throw BiometryAuthenticationError(error: error)
        }
    }
}
