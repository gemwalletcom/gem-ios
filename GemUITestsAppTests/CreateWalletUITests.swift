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
        app.activate()

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

        // System push permission
        app.allowNotifications()

        // WalletScene
        app.buttons["Wallet #1"].firstMatch.tap()

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
