// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class ImportWalletReceiveBitcoinUITests: XCTestCase {

    enum Constants {
        static let words = "insect select insane waste rate grit ranch uniform loan venture jump silent"
        static let address = "bc1qvxn5cxtp63cylys56mdwzrdmeryj608vlsexkw"
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testImportMultiCoinWalletAndVerifyBitcoinAddress() throws {
        let app = XCUIApplication()
        app.activate()

        // OnboardingScene
        app.buttons["Import an Existing Wallet"].firstMatch.tap()

        // AcceptTermsScene
        app.acceptTerms()

        // ImportWalletTypeScene
        app.buttons["Multi-Coin"].firstMatch.tap()

        // ImportWalletScene
        app.textFields["importInputField"].typeText(Constants.words)
        app.buttons["Import"].firstMatch.tap()

        // System push permission
        app.allowNotifications()

        // WalletScene
        app.buttons["receive_button"].firstMatch.tap()

        // SelectAssetScene
        app.buttons["Bitcoin, BTC"].firstMatch.tap()

        // ReceiveScene
        app.buttons["Copy"].firstMatch.tap()
        XCTAssertTrue(app.buttons[Constants.address].exists)
    }
}
