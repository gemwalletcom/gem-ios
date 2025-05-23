// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class SecurityReminderRobot: Robot {
    
    @discardableResult
    func checkScreen() -> Self {
        assert(safariInfoButton, [.exists, .isHittable])
        assert(stateButton, [.exists, .isHittable, .isEnabled])
        
        return self
    }
    
    @discardableResult
    func tapContinue() -> CreateWalletSceneRobot {
        tap(stateButton)
        
        return CreateWalletSceneRobot(app)
    }
}
