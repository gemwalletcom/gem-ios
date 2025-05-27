// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class OnboardingSceneRobot: Robot {
    private lazy var createButton = app.buttons["welcome_create"]
    private lazy var importButton = app.buttons["welcome_import"]
    
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
