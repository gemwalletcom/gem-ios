// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class CreateWalletUITests: XCTestCase {

    func testCreateFirstWalletFlow() {
        let app = XCUIApplication()
        CreateWalletNavigationStackRobot(app)
            .startCreateFirstWalletFlow()
        
        AcceptTermsSceneRobot(app)
            .checkScene()
            .checkTitle(contains: "Accept Terms")
            .acceptTermsToggle(at: 0)
            .acceptTermsToggle(at: 1)
            .acceptTermsToggle(at: 2)
            .tapContinueButton()

        SecurityReminderSceneRobot(app)
            .checkScene()
            .checkTitle(contains: "New Wallet")
            .checkBackButton(title: "Accept Terms")
            .tapContinueButton()
        
        CreateWalletSceneRobot(app)
            .checkScene()
            .checkTitle(contains: "New Wallet")
            .checkBackButton(title: "New Wallet")
            .tapContinueButton()
        
        VerifyPhraseWalletSceneRobot(app)
            .checkScene()
            .checkTitle(contains: "Confirm")
            .checkBackButton(title: "New Wallet")
            .verifyPhrase()
            .tapContinueButton()
    }
    
    func testCreateWalletFlow() {
        let app = XCUIApplication()
        CreateWalletNavigationStackRobot(app)
            .startCreateWalletFlow()
        
        SecurityReminderSceneRobot(app)
            .checkBackButton(title: "Cancel")
            .tapContinueButton()
        
        CreateWalletSceneRobot(app)
            .tapContinueButton()
        
        VerifyPhraseWalletSceneRobot(app)
            .verifyPhrase()
            .tapContinueButton()
    }
}
