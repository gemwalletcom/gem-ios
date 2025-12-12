// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct WalletDetailScene {
    let app: XCUIApplication

    @discardableResult
    func tapShowSecretPhrase() -> Self {
        app.buttons["Show Secret Phrase"].firstMatch.tap()
        return self
    }

    @discardableResult
    func tapDelete() -> Self {
        app.buttons["Delete"].firstMatch.tap()
        return self
    }

    @discardableResult
    func confirmDelete() -> Self {
        app.alerts.buttons["Delete"].tap()
        return self
    }
}
