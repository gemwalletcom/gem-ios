// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StoreKit
import Preferences

public struct RateService: Sendable {
    private let preferences: Preferences

    public init(preferences: Preferences) {
        self.preferences = preferences
    }

    public func perform() {
#if targetEnvironment(simulator)
#else
        if preferences.launchesCount >= 5 && !preferences.rateApplicationShown {
            Task { @MainActor in
                if rate() {
                    preferences.rateApplicationShown = true
                }
            }
        }
#endif
    }

    @MainActor
    @discardableResult
    private func rate() -> Bool {
        guard let scene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return false }
        AppStore.requestReview(in: scene)
        return true
    }
}
