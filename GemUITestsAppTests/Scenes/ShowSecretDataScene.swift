// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct ShowSecretDataScene {
    let app: XCUIApplication

    func getWords() -> [String] {
        (0..<12).map { app.staticTexts["word_\($0)"].label }
    }

    @discardableResult
    func tapContinue() -> Self {
        app.continueButton.tap()
        return self
    }
}
