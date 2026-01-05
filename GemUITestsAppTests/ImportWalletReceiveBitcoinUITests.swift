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

        // OnboardingScene
        if app.isOnboarding {        
            app.tapImportWallet()
        }

        // AcceptTermsScene
        app.acceptTerms()

        importFlow(app: app, words: UITestKitConstants.words)

        // WalletScene
        app.buttons["receive_button"].firstMatch.tap()

        // SelectAssetScene
        app.buttons["Bitcoin, BTC"].firstMatch.tap()

        // ReceiveScene
        app.buttons["Copy"].firstMatch.tap()
        XCTAssertTrue(app.buttons[UITestKitConstants.bitcoinAddress].exists)
        
        app.tapBack()
        app.tapBack()
        app.tapWalletBar()

        // WalletsScene - import second wallet
        app.tapImportWallet()

        importFlow(app: app, words: UITestKitConstants.words2)
    }
    
    func importFlow(app: XCUIApplication, words: String) {
        // ImportWalletTypeScene
        app.buttons["Multi-Coin"].firstMatch.tap()

        // ImportWalletScene
        app.textFields["importInputField"].typeText(words)
        app.buttons["Import"].firstMatch.tap()
        
        // SetupWalletScene
        app.buttons["Done"].firstMatch.tap()
    }
}
