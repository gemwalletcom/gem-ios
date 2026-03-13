// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class UpgradeVerificationTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testWalletSurvivedUpgrade() throws {
        let app = XCUIApplication()
        setupPermissionHandler()
        app.launch()

        XCTAssertFalse(app.isOnboarding, "App should not show onboarding after upgrade — wallet data was lost")

        // WalletScene
        let receiveButton = app.buttons["receive_button"].firstMatch
        XCTAssertTrue(receiveButton.waitForExistence(timeout: 10), "receive_button not found")
        receiveButton.tap()

        // SelectAssetScene
        let bitcoinButton = app.buttons["Bitcoin, BTC"].firstMatch
        XCTAssertTrue(bitcoinButton.waitForExistence(timeout: 10), "Bitcoin asset not found after upgrade")
        bitcoinButton.tap()

        // ReceiveScene
        let copyButton = app.buttons["Copy"].firstMatch
        XCTAssertTrue(copyButton.waitForExistence(timeout: 10), "Copy button not found")
        copyButton.tap()
    }
}
