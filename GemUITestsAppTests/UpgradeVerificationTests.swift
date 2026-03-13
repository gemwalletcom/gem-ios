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
        app.buttons["receive_button"].firstMatch.tap()

        // SelectAssetScene
        app.buttons["Bitcoin, BTC"].firstMatch.tap()

        // ReceiveScene
        app.buttons["Copy"].firstMatch.tap()
        XCTAssertTrue(app.buttons[UITestKitConstants.bitcoinAddress].exists, "Bitcoin address mismatch after upgrade")
    }
}
