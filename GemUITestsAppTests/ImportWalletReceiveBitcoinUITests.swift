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
        app.launch()
        app.logout()

        OnboardingScene(app: app)
            .tapImportWallet()

        AcceptTermsScene(app: app)
            .acceptIfNeeded()

        ImportWalletTypeScene(app: app)
            .tapMultiCoin()

        ImportWalletScene(app: app)
            .enterPhrase(UITestKitConstants.words)
            .tapImport()

        WalletScene(app: app)
            .tapReceive()

        SelectAssetScene(app: app)
            .tapAsset("Bitcoin, BTC")

        let receiveScene = ReceiveScene(app: app)
            .tapCopy()

        XCTAssertTrue(receiveScene.addressExists(UITestKitConstants.bitcoinAddress))
    }
}
