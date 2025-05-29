// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class ImportWalletUITests: XCTestCase {

    func testMulticoinImportWalletFlow() {
        let app = XCUIApplication()
        ImportWalletNavigationStackRobot(app)
            .startImportWalletFlow()
        
        ImportWalletTypeSceneRobot(app)
            .checkScene()
            .checkBackButton(title: "Cancel")
            .checkTitle(contains: "Import Wallet")
            .checkSearchEmpty()
            .checkSearchNotEmpty()
            .tapMulticoin()
        
        ImportWalletSceneRobot(app)
            .checkScene()
            .checkWalletName("Wallet #1")
            .checkBackButton(title: "Import Wallet")
            .checkTitle(contains: "Multi-Coin")
            .renameWallet()
            .insertIncorrectPhrase()
            .insertCorrectPhrase()
            .tapContinueButton()
    }

    func testEthereumImportPrivateKey() {
        let app = XCUIApplication()
        ImportWalletNavigationStackRobot(app)
            .startImportWalletFlow()
        
        ImportWalletTypeSceneRobot(app)
            .tapEthereum()
        
        ImportWalletSceneRobot(app)
            .checkTitle(contains: "Ethereum")
            .checkSegmentedControl()
            .tapToPrivateKey()
            .insertPrivateKey()
            .tapContinueButton()
    }
    
    func testEthereumImportAddress() {
        let app = XCUIApplication()
        ImportWalletNavigationStackRobot(app)
            .startImportWalletFlow()
        
        ImportWalletTypeSceneRobot(app)
            .tapEthereum()
        
        ImportWalletSceneRobot(app)
            .tapToAddress()
            .insertAddress()
            .tapContinueButton()
    }
}
