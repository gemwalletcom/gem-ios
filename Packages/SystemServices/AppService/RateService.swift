// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StoreKit
import Preferences

struct RateService {
    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func perform() {
#if targetEnvironment(simulator)
#else
        if preferences.launchesCount >= 5 && !preferences.rateApplicationShown {
            Task { @MainActor in
                rate()
                preferences.rateApplicationShown = true
            }
        }
#endif
    }
}

// MARK: - Private

extension RateService {
    @MainActor
    private func rate() {
        guard let scene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        AppStore.requestReview(in: scene)
    }
}
