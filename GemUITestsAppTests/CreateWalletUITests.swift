// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class CreateWalletUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testImportWalletAndReceiveBitcoin() throws {
        let app = XCUIApplication()
        setupPermissionHandler()
        app.launch()
        app.logout()

        OnboardingScene(app: app)
            .tapCreateWallet()

        AcceptTermsScene(app: app)
            .acceptIfNeeded()

        SecurityReminderScene(app: app)
            .tapContinue()

        let showSecretData = ShowSecretDataScene(app: app)
        let words = showSecretData.getWords()
        showSecretData.tapContinue()

        VerifyPhraseScene(app: app)
            .tapWords(words)
            .tapContinue()

        WalletScene(app: app)
            .tapWallet(UITestKitConstants.defaultWalletName)
            .tapSettings()
            .tapShowSecretPhrase()

        SecurityReminderScene(app: app)
            .tapContinue()

        let displayedWords = ShowSecretDataScene(app: app).getWords()
        XCTAssertEqual(words, displayedWords)
    }
}
