// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct WalletScene {
    let app: XCUIApplication

    @discardableResult
    func tapReceive() -> Self {
        app.buttons["receive_button"].firstMatch.tap()
        return self
    }

    @discardableResult
    func tapWallet(_ name: String) -> WalletsScene {
        app.buttons[name].firstMatch.tap()
        return WalletsScene(app: app)
    }
}
