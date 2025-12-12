// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct SelectAssetScene {
    let app: XCUIApplication

    @discardableResult
    func tapAsset(_ name: String) -> Self {
        app.buttons[name].firstMatch.tap()
        return self
    }
}
