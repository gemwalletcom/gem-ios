// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest

@MainActor
final class OnboardingUITests: XCTestCase {
    private lazy var app = XCUIApplication()
    
    func testOnboarding() {
        OnboardingNavigationViewRobot()
            .startOnboarding()

        OnboardingSceneRobot(app)
            .checkScene()
    }
}
