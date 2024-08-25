// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

final class CreateWalletUITests: XCTestCase {

//    var app: XCUIApplication!
//
//    override func setUp() {
//        super.setUp()
//        continueAfterFailure = false
//
//        app = XCUIApplication()
//        if app.state == .runningForeground {
//            app.terminate()
//        }
//        app.launch()
//    }
//
//    override func tearDown() {
//        app.terminate()
//
//        super.tearDown()
//    }

    func testCreateWallet() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.buttons["Create a New Wallet"].exists)
        XCTAssert(app.buttons["Import an Existing Wallet"].exists)

        app.buttons.element(matching: .button, identifier: "Create a New Wallet").tap()

        XCTAssert(app.navigationBars["New Wallet"].exists)
        XCTAssert(app.buttons["Continue"].exists)
    }
}
