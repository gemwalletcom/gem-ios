// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct OnboardingScene {
    let app: XCUIApplication

    var isVisible: Bool {
        app.buttons["Create a New Wallet"].exists
    }

    @discardableResult
    func tapCreateWallet() -> Self {
        app.buttons["Create a New Wallet"].firstMatch.tap()
        return self
    }

    @discardableResult
    func tapImportWallet() -> Self {
        app.buttons["Import an Existing Wallet"].firstMatch.tap()
        return self
    }
}
