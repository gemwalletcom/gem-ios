// Copyright (c). Gem Wallet. All rights reserved.

import Foundation


final class OnboardingRobot: Robot {
    private lazy var createButton = app.buttons["welcome_create"]
    private lazy var importButton = app.buttons["welcome_import"]
    
    func start() -> Self {
        start(launchEnvironment: .onboarding, timeout: 5)
    }
    
    @discardableResult
    func checkOnboardingScreenVisible(timeout: TimeInterval = 5) -> Self {
        assert(createButton, [.exists, .isHittable], timeout: timeout)
        assert(importButton, [.exists, .isHittable], timeout: timeout)
        return self
    }
    
    @discardableResult
    func tapCreateButton() -> Self {
        tap(createButton)
    }
    
    @discardableResult
    func tapImportButton() -> Self {
        tap(importButton)
    }
}
