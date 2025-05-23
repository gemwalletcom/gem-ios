// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class CreateWalletUITests: XCTestCase {

    func testCreateFirstWalletFlow() {
        let app = XCUIApplication()
        CreateWalletFlowLauncher(app)
            .startCreateFirstWalletFlow()
        
        AcceptTermsSceneRobot(app)
            .checkScreen()
            .checkTitle(contains: "Accept Terms")
            .acceptTermsToggle(at: 0)
            .acceptTermsToggle(at: 1)
            .acceptTermsToggle(at: 2)
            .tapContinueButton()

        SecurityReminderRobot(app)
            .checkScreen()
            .checkTitle(contains: "New Wallet")
            .checkBackButton(title: "Accept Terms")
            .tapContinue()
        
        CreateWalletSceneRobot(app)
            .checkScreen()
            .checkTitle(contains: "New Wallet")
            .checkBackButton(title: "New Wallet")
            .tapContinueButton()
        
        VerifyPhraseWalletSceneRobot(app)
            .checkScreen()
            .checkTitle(contains: "Confirm")
            .checkBackButton(title: "New Wallet")
            .verifyPhrase()
            .tapContinue()
    }
    
    func testCreateWalletFlow() {
        let app = XCUIApplication()
        CreateWalletFlowLauncher(app)
            .startCreateWalletFlow()
        
        SecurityReminderRobot(app)
            .checkBackButton(title: "Cancel")
            .tapContinue()
        
        CreateWalletSceneRobot(app)
            .tapContinueButton()
        
        VerifyPhraseWalletSceneRobot(app)
            .verifyPhrase()
            .tapContinue()
    }
}
