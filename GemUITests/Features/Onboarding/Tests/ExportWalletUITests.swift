// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest

@MainActor
final class ExportWalletUITests: XCTestCase {
    
    func testExportWords() {
        let app = XCUIApplication()
        
        ExportWalletNavigationStackRobot(app)
            .startExportWordsFlow()
        
        SecurityReminderSceneRobot(app)
            .checkScene()
            .checkTitle(contains: "Secret Phrase")
            .tapContinueButton()
        
        ShowSecretDataSceneRobot(app)
            .checkBackButton(title: "Secret Phrase")
            .checkTitle(contains: "Secret Phrase")
            .checkWordsScene()
            .checkCopyButton()
    }
    
    func testExportPrivateKey() {
        let app = XCUIApplication()
        
        ExportWalletNavigationStackRobot(app)
            .startExportPrivateKeyFlow()
        
        ShowSecretDataSceneRobot(app)
            .checkPrivateKeyScene()
            .checkTitle(contains: "Private Key")
            .checkBackButton(title: "Cancel")
    }
}
