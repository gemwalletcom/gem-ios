// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

@testable import Onboarding

final class OnboardingSceneRobot: Robot {
    private lazy var createButton = app.buttons[OnboardingAccessibilityIdentifier.onboardingCreateButton.id]
    private lazy var importButton = app.buttons[OnboardingAccessibilityIdentifier.onboardingImportButton.id]
    
    @discardableResult
    func checkScene() -> Self {
        assert(createButton, [.exists, .isHittable])
        assert(importButton, [.exists, .isHittable])
        return self
    }
    
    func tapCreateButton() {
        tap(createButton)
    }

    func tapImportButton() {
        tap(importButton)
    }
}
