// Copyright (c). Gem Wallet. All rights reserved.

import LocalAuthentication

public struct BiometryAuthentificationService: BiometryAuthentifiable {
    private let keystorePassword: KeystorePassword

    public init(keystorePassword: KeystorePassword = LocalKeystorePassword()) {
        self.keystorePassword = keystorePassword
    }

    public var isAuthenticationEnabled: Bool {
        availableAuthentication != .none
    }

    public var availableAuthentication: KeystoreAuthentication {
        keystorePassword.getAvailableAuthentication()
    }

    public func enableAuthentication(_ enable: Bool, context: LAContext, reason: String) async throws {
        do {
            try await authenticate(context: context, reason: reason)
            try keystorePassword.enableAuthentication(enable, context: context)
        } catch let error as NSError {
            throw BiometryAuthentificationError(error: error)
        }
    }

    public func authenticate(context: LAContext, reason: String) async throws {
        try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
    }
}
