// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Components
import LocalAuthentication

class SecurityViewModel: ObservableObject {
    
    let keystorePassword = LocalKeystorePassword()
    
    var title: String {
        return Localized.Settings.security
    }
    
    var authenticationTitle: String {
        switch try! keystorePassword.getAvailableAuthentication() {
        case .biometrics:
            return Localized.Settings.enableValue("Face ID")
        case .none, .passcode:
            return Localized.Settings.enablePasscode
        }
    }
    
    var authenticationEnabled: Bool {
        guard let authentication = try? keystorePassword.getAuthentication() else {
            return false
        }
        switch authentication {
        case .biometrics, .passcode:
            return true
        case .none:
            return false
        }
    }
    
    func changeEnableBiometrics(value: Bool, context: LAContext) throws {
        try keystorePassword.enableAuthentication(value, context: context)
    }
}
