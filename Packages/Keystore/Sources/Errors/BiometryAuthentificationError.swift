// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import LocalAuthentication

public enum BiometryAuthentificationError: Error {
    case biometryUnavailable
    case canceled
    case authenticationFailed

    init(error: NSError) {
        switch error.code {
        case LAError.biometryNotAvailable.rawValue,
            LAError.passcodeNotSet.rawValue:
            self = .biometryUnavailable
        case LAError.userCancel.rawValue,
            LAError.userFallback.rawValue,
            LAError.biometryLockout.rawValue,
            LAError.systemCancel.rawValue,
            LAError.appCancel.rawValue:
            self = .canceled
        default:
            self = .authenticationFailed
        }
    }

    public var isAuthCanceled: Bool {
        switch self {
        case .canceled: true
        case .biometryUnavailable, .authenticationFailed: false
        }
    }
}
