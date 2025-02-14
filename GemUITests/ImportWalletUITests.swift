// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

final class ImportWalletUITests: XCTestCase {

    func testImportWallet() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.buttons["Create a New Wallet"].exists)
        XCTAssert(app.buttons["Import an Existing Wallet"].exists)

        app.buttons.element(matching: .button, identifier: "Import an Existing Wallet").tap()

        XCTAssert(app.buttons["Multi-Coin"].exists)
    }
}
