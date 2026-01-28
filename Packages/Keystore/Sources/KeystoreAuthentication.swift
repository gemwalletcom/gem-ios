// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keychain
import LocalAuthentication

public enum KeystoreAuthentication: String, Sendable {
    case biometrics
    case passcode
    case none
}

extension KeystoreAuthentication {
    var policy: AuthenticationPolicy {
        switch self {
        case .biometrics:
            return [.biometryAny, .or, .devicePasscode]
        case .passcode:
            return [.devicePasscode]
        case .none:
            return []
        }
    }
    
    static var availableAuthenticationType: KeystoreAuthentication {
        let context = LAContext()
        do {
            try context.canEvaluatePolicyThrowing(policy: .deviceOwnerAuthenticationWithBiometrics)
            return .biometrics
        } catch {
            do {
                try context.canEvaluatePolicyThrowing(policy: .deviceOwnerAuthentication)
                return .passcode
            } catch {
                return .none
            }
        }
    }
}
