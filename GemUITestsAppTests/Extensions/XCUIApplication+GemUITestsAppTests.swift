// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

extension XCUIApplication {
    
    var isOnboarding: Bool {
        buttons["Create a New Wallet"].exists
    }

    func acceptTerms() {
        if buttons["Agree and Continue"].exists {
            switches.allElementsBoundByIndex.forEach { $0.tap() }
            buttons["Agree and Continue"].firstMatch.tap()
        }
    }

    func tapContinue() {
        buttons["Continue"].firstMatch.tap()
    }

    func tapBack() {
        navigationBars.buttons.element(boundBy: 0).tap()
    }

    func getWords() -> [String] {
        (0..<12).map { staticTexts["word_\($0)"].label }
    }
    
    func tapWalletBar() {
        let walletBar = buttons["walletBar"].firstMatch
        XCTAssertTrue(walletBar.waitForExistence(timeout: 2), "walletBar not found")
        walletBar.tap()
    }
    
    func logout() {
        if isOnboarding == false {
            buttons["Wallet"].firstMatch.tap()
            tapWalletBar()
            while buttons["gearshape"].waitForExistence(timeout: 2) {
                // WalletsScene
                buttons["gearshape"].firstMatch.tap()
                // WalletDetailScene
                buttons["Delete"].firstMatch.tap()
                // Delete confirmation alert
                alerts.buttons["Delete"].tap()
            }
        }
    }
    
    func tapCreateWallet() {
        buttons["Create a New Wallet"].firstMatch.tap()
    }
    
    func tapImportWallet() {
        let button = buttons["Import an Existing Wallet"].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 2), "button not found")
        button.tap()
    }
}
