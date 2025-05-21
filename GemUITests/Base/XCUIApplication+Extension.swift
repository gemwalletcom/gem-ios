// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

extension XCUIApplication {
    func setLaunchEnvironment(_ environment: UITestLaunchScenario) {
        launchEnvironment["GemAppUITesting"] = environment.rawValue
    }
}
