// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
struct ReceiveScene {
    let app: XCUIApplication

    func addressExists(_ address: String) -> Bool {
        app.buttons[address].exists
    }

    @discardableResult
    func tapCopy() -> Self {
        app.buttons["Copy"].firstMatch.tap()
        return self
    }
}
