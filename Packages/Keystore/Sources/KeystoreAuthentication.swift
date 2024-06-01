// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import KeychainAccess
import LocalAuthentication

public enum KeystoreAuthentication: String {
    case biometrics
    case passcode
    case none
}

public extension KeystoreAuthentication {
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
