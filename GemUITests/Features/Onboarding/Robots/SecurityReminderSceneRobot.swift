// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class SecurityReminderSceneRobot: Robot {
    
    @discardableResult
    func checkScene() -> Self {
        assert(safariInfoButton, [.exists, .isHittable])
        assert(stateButton, [.exists, .isHittable, .isEnabled])
        
        return self
    }

    func tapContinueButton() {
        tap(stateButton)
    }
}
