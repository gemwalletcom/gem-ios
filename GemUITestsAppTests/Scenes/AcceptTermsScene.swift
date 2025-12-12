// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct AcceptTermsScene {
    let app: XCUIApplication

    var isVisible: Bool {
        app.buttons["Agree and Continue"].exists
    }

    @discardableResult
    func toggleAllSwitches() -> Self {
        app.switches.allElementsBoundByIndex.forEach { $0.tap() }
        return self
    }

    @discardableResult
    func tapAgree() -> Self {
        app.buttons["Agree and Continue"].firstMatch.tap()
        return self
    }

    @discardableResult
    func acceptIfNeeded() -> Self {
        if isVisible {
            toggleAllSwitches()
            tapAgree()
        }
        return self
    }
}
