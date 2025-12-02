// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class ImportWalletReceiveBitcoinUITests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testImportMultiCoinWalletAndVerifyBitcoinAddress() throws {
        let app = XCUIApplication()
        setupPermissionHandler()
        app.activate()

        // OnboardingScene
        app.buttons["Import an Existing Wallet"].firstMatch.tap()

        // AcceptTermsScene
        app.acceptTerms()

        // ImportWalletTypeScene
        app.buttons["Multi-Coin"].firstMatch.tap()

        // ImportWalletScene
        app.textFields["importInputField"].typeText(UITestKitConstants.words)
        app.buttons["Import"].firstMatch.tap()

        // WalletScene
        app.buttons["receive_button"].firstMatch.tap()

        // SelectAssetScene
        app.buttons["Bitcoin, BTC"].firstMatch.tap()

        // ReceiveScene
        app.buttons["Copy"].firstMatch.tap()
        XCTAssertTrue(app.buttons[UITestKitConstants.bitcoinAddress].exists)
    }
}
