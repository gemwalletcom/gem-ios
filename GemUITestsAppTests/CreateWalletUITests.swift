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

        // OnboardingScene
        app.buttons["Create a New Wallet"].firstMatch.tap()

        // AcceptTermsScene
        app.acceptTerms()

        // SecurityReminderScene
        app.tapContinue()

        // ShowSecretDataScene
        let words = app.getWords()
        app.tapContinue()

        // VerifyPhraseWalletScene
        words.forEach { app.buttons[$0].firstMatch.tap() }
        app.tapContinue()

        // WalletScene
        app.tapWalletBar()

        // WalletsScene
        app.buttons["gearshape"].firstMatch.tap()

        // WalletDetailScene
        app.buttons["Show Secret Phrase"].firstMatch.tap()

        // SecurityReminderScene
        app.tapContinue()

        // ShowSecretDataScene
        let displayedWords = app.getWords()
        XCTAssertEqual(words, displayedWords)
    }
}
