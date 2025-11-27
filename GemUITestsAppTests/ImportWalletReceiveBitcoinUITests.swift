// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class ImportWalletReceiveBitcoinUITests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testImportWalletAndReceiveBitcoin() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Import an Existing Wallet"].firstMatch.tap()
        app.staticTexts["I understand that I am solely responsible for the security and backup of my wallets, not Gem."].firstMatch.tap()
        app.staticTexts["I understand that Gem is not a bank or exchange, and using it for illegal purposes is strictly prohibited."].firstMatch.tap()
        app.staticTexts["I understand that if I ever lose access to my wallets, Gem is not liable and cannot help in any way."].firstMatch.tap()
        app.buttons["Agree and Continue"].firstMatch.tap()

        app.buttons["Multi-Coin"].firstMatch.tap()
        
        let activeField = app.textFields.matching(NSPredicate(format: "hasKeyboardFocus == true")).firstMatch
        activeField.typeText("insect select insane waste rate grit ranch uniform loan venture jump silent")
        app.buttons["Import"].firstMatch.tap()
        
        let springboardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboardApp.buttons["Allow"].firstMatch.tap()
        
        app.images["qrcode"].firstMatch.tap()

        app.buttons["Bitcoin, BTC"].firstMatch.tap()

        app.buttons["Copy"].firstMatch.tap()
        
        let bitcoinAddress = app.buttons["bc1qvxn5cxtp63cylys56mdwzrdmeryj608vlsexkw"]
        XCTAssertTrue(bitcoinAddress.exists)
    }
}
