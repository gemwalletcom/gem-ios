// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components

final class CreateFirstWalletRobot: Robot {
    
    func start() -> Self {
        start(scenario: .createFirstWallet)
        
        return self
    }
    
    @discardableResult
    func checkScreen() -> Self {
        assert(safariInfoButton, [.exists, .isHittable])
        assert(stateButton, [.exists, .isNotEnabled])
        
        return self
    }
    
    @discardableResult
    func acceptTermsToggle(at index: Int) -> Self {
        let toggle = app.switches[AccessibilityIdentifier.Onboarding.acceptTermsToggle(index).id]
        assert(toggle, [.exists, .isOff])
        tap(toggle)
        assert(toggle, [.isOn])
        
        return self
    }
    
    @discardableResult
    func tapContinueButton() -> SecurityReminderRobot {
        assert(stateButton, [.isEnabled])
        tap(stateButton)

        return SecurityReminderRobot(app)
    }
}
