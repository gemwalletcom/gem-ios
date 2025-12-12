// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct WalletsScene {
    let app: XCUIApplication

    @discardableResult
    func tapSettings() -> WalletDetailScene {
        app.buttons["gearshape"].firstMatch.tap()
        return WalletDetailScene(app: app)
    }
}
