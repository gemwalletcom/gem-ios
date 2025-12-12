// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct ImportWalletTypeScene {
    let app: XCUIApplication

    @discardableResult
    func tapMultiCoin() -> Self {
        app.buttons["Multi-Coin"].firstMatch.tap()
        return self
    }
}
