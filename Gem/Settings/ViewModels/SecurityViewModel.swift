// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Components
import Localization

@Observable
class SecurityViewModel {
    private let service: any BiometryAuthenticatable
    private let preferences: ObservablePreferences

    static let reason: String = Localized.Settings.Security.authentication

    var isPresentingError: String?
    var isEnabled: Bool
    var isPrivacyLockEnabled: Bool
    var isBalancePrivacyEnabled: Bool {
        get {
            preferences.isBalancePrivacyEnabled
        }
        set {
            preferences.isBalancePrivacyEnabled = newValue
        }
    }

    var lockPeriodModel: LockPeriodSelectionViewModel

    init(service: any BiometryAuthenticatable = BiometryAuthenticationService(),
         preferences: ObservablePreferences = .default) {

        self.service = service
        self.preferences = preferences

        self.lockPeriodModel = LockPeriodSelectionViewModel(service: service)
        self.isEnabled = service.isAuthenticationEnabled
        self.isPrivacyLockEnabled = service.isPrivacyLockEnabled
    }

    var title: String { Localized.Settings.security }
    var errorTitle: String { Localized.Errors.errorOccured }
    var privacyLockTitle: String { Localized.Lock.privacyLock }
    var balacePrivacyTitle: String { Localized.Settings.balancePrivacy }

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

    func togglePrivacyLock() {
        guard isPrivacyLockEnabled != service.isPrivacyLockEnabled else { return }
        do {
            try service.togglePrivacyLock(enbaled: isPrivacyLockEnabled)
        } catch {
            isPresentingError = error.localizedDescription
            isPrivacyLockEnabled.toggle()
        }
    }
}
