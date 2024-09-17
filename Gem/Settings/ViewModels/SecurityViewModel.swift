// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Components
import Store

@Observable
class SecurityViewModel {
    private let service: BiometryAuthentifiable

    var isPresentingError: String?
    var isEnabled: Bool

    var lockPeriodModel: LockPeriodSelectionViewModel

    init(service: BiometryAuthentifiable = BiometryAuthentificationService(),
         lockPeriodModel: LockPeriodSelectionViewModel = LockPeriodSelectionViewModel()
    ) {
        self.service = service
        self.isEnabled = service.isAuthenticationEnabled
        self.lockPeriodModel = lockPeriodModel
    }

    var title: String {
        Localized.Settings.security
    }

    var authenticationTitle: String {
        switch service.availableAuthentication {
        case .biometrics: Localized.Settings.enableValue("Face ID")
        case .passcode, .none: Localized.Settings.enablePasscode
        }
    }

    static var reason: String {
        Localized.Settings.Security.authentication
    }
}

// MARK: - Business Logic

extension SecurityViewModel {
    func toggleBiometrics() async {
        guard isEnabled != service.isAuthenticationEnabled else { return }
        do {
            try await service.enableAuthentication(isEnabled, reason: SecurityViewModel.reason)
        } catch let error as BiometryAuthentificationError {
            if !error.isAuthCanceled {
                isPresentingError = error.localizedDescription
            }
            isEnabled = !isEnabled
        } catch {
            isPresentingError = error.localizedDescription
            isEnabled = !isEnabled
        }
    }
}
