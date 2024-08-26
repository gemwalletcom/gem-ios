// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

final class ImportWalletUITests: XCTestCase {

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

    func testImportWallet() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.buttons["Create a New Wallet"].exists)
        XCTAssert(app.buttons["Import an Existing Wallet"].exists)

        //app.buttons.element(matching: .button, identifier: "Import an Existing Wallet").tap()

        //XCTAssert(app.buttons["Multi-Coin"].exists)
    }
}
