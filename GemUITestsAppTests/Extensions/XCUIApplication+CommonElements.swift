// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

extension XCUIApplication {

    var continueButton: XCUIElement {
        buttons["Continue"].firstMatch
    }

    var backButton: XCUIElement {
        navigationBars.buttons.element(boundBy: 0)
    }
}
