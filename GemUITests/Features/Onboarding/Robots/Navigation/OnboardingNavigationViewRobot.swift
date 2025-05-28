// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class OnboardingNavigationViewRobot: Robot {
    func startOnboarding() {
        start(scenario: .onboarding)
    }
}
