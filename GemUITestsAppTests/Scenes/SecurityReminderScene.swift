// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct SecurityReminderScene {
    let app: XCUIApplication

    @discardableResult
    func tapContinue() -> Self {
        app.continueButton.tap()
        return self
    }
}
