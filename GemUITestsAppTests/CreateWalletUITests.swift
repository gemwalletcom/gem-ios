// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class CreateWalletUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testCreateWalletAndReceiveBitcoin() throws {
        let app = XCUIApplication()
        setupPermissionHandler()
        app.launch()
        app.logout()

        // OnboardingScene
        if app.isOnboarding {
            app.tapCreateWallet()            
        }
        
        let words = creationFlow(app: app, checkShowSecretDataScene: true)

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
        
        // Back to WalletsScene
        app.tapBack()
        app.tapBack()
        app.tapBack()
        
        app.tapCreateWallet()
        
        let _ = creationFlow(app: app, checkShowSecretDataScene: false)
        
        // SetupWalletScene
        app.buttons["Done"].firstMatch.tap()
    }
    
    private func creationFlow(app: XCUIApplication, checkShowSecretDataScene: Bool) -> [String] {
        // AcceptTermsScene
        app.acceptTerms()

        // SecurityReminderScene
        app.tapContinue()

        // ShowSecretDataScene
        let words = app.getWords()
        app.tapContinue()
        
        if checkShowSecretDataScene {
            app.tapBack()
            words.forEach { XCTAssert(app.staticTexts[$0].exists) }
        }
        app.tapContinue()

        // VerifyPhraseWalletScene
        words.forEach { app.buttons[$0].firstMatch.tap() }
        app.tapContinue()
        
        return words
    }
}
