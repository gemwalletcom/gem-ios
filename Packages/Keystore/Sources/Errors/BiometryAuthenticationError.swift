// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import LocalAuthentication

public enum BiometryAuthenticationError: Error {
    case biometryUnavailable
    case canceled
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
                self = .canceled
            default:
                self = .authenticationFailed
            }
        default:
            self = .authenticationFailed
        }
    }

    public var isAuthCancelled: Bool {
        switch self {
        case .canceled: true
        case .biometryUnavailable, .authenticationFailed: false
        }
    }
}
