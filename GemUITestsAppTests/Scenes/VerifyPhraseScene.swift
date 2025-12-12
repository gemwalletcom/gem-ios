// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct VerifyPhraseScene {
    let app: XCUIApplication

    @discardableResult
    func tapWords(_ words: [String]) -> Self {
        words.forEach { app.buttons[$0].firstMatch.tap() }
        return self
    }

    @discardableResult
    func tapContinue() -> Self {
        app.continueButton.tap()
        return self
    }
}
