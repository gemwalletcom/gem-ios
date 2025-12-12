// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct ImportWalletScene {
    let app: XCUIApplication

    @discardableResult
    func enterPhrase(_ phrase: String) -> Self {
        app.textFields["importInputField"].typeText(phrase)
        return self
    }

    @discardableResult
    func tapImport() -> Self {
        app.buttons["Import"].firstMatch.tap()
        return self
    }
}
