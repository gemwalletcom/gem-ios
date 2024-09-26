// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Components
import Store

@Observable
class SecurityViewModel {
    private let preferences: Preferences
    private let service: BiometryAuthenticatable

    static let reason: String = Localized.Settings.Security.authentication

    var isPresentingError: String?
    var isEnabled: Bool
    var isPrivacyLockEnabled: Bool {
        didSet {
            preferences.isPrivacyLockEnabled = isPrivacyLockEnabled
        }
    }

    var lockPeriodModel: LockPeriodSelectionViewModel

    init(service: BiometryAuthenticatable = BiometryAuthenticationService(),
         preferences: Preferences = .main) {
        self.service = service
        self.preferences = preferences

        self.lockPeriodModel = LockPeriodSelectionViewModel(service: service)
        self.isEnabled = service.isAuthenticationEnabled
        self.isPrivacyLockEnabled = preferences.isPrivacyLockEnabled
    }

    var title: String { Localized.Settings.security }
    var errorTitle: String { Localized.Errors.errorOccured }
    var privacyLockTitle: String { Localized.Lock.privacyLock }

    var authenticationTitle: String {
        switch service.availableAuthentication {
        case .biometrics: Localized.Settings.enableValue("Face ID")
        case .passcode, .none: Localized.Settings.enablePasscode
        }
    }
}

// MARK: - Business Logic

extension SecurityViewModel {
    func toggleBiometrics() async {
        guard isEnabled != service.isAuthenticationEnabled else { return }
        do {
            try await service.enableAuthentication(isEnabled, reason: SecurityViewModel.reason)
        } catch let error as BiometryAuthenticationError {
            if !error.isAuthenticationCancelled {
                isPresentingError = error.localizedDescription
            }
            isEnabled.toggle()
        } catch {
            isPresentingError = error.localizedDescription
            isEnabled.toggle()
        }
    }
}
