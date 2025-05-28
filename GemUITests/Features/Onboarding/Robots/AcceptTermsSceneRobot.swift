// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components

@testable import Onboarding

final class AcceptTermsSceneRobot: Robot {
    
    @discardableResult
    func checkScene() -> Self {
        assert(safariInfoButton, [.exists, .isHittable])
        assert(stateButton, [.exists, .isNotEnabled])
        
        return self
    }
    
    @discardableResult
    func acceptTermsToggle(at index: Int) -> Self {
        let toggle = app.switches[OnboardingAccessibilityIdentifier.acceptTermsToggle(index).id]
        assert(toggle, [.exists, .isOff])
        tap(toggle)
        assert(toggle, [.isOn])
        
        return self
    }
    
    func tapContinueButton() {
        assert(stateButton, [.isEnabled])
        tap(stateButton)
    }
}
