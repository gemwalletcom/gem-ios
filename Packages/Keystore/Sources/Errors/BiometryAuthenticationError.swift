// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import LocalAuthentication

public enum BiometryAuthenticationError: Error {
    case biometryUnavailable
    case cancelled
    case authenticationFailed

    init(error: NSError) {
        switch error {
        case let urlError as LAError:
            switch urlError {
            case LAError.biometryNotAvailable,
                LAError.passcodeNotSet:
                self = .biometryUnavailable
            case LAError.userCancel,
                LAError.userFallback,
                LAError.biometryLockout,
                LAError.systemCancel,
                LAError.appCancel:
                self = .cancelled
            default:
                self = .authenticationFailed
            }
        default:
            self = .authenticationFailed
        }
    }

    public var isAuthenticationCancelled: Bool {
        switch self {
        case .cancelled: true
        case .biometryUnavailable, .authenticationFailed: false
        }
    }
}
