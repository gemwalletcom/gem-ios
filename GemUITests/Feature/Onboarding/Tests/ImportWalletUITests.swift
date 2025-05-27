// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

@MainActor
final class ImportWalletUITests: XCTestCase {

    func testMulticoinImportWalletFlow() {
        let app = XCUIApplication()
        ImportWalletFlowLauncher(app)
            .start()
        
        ImportWalletTypeSceneRobot(app)
            .checkScreen()
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
            .tapContinue()
    }

    func testEthereumImportPrivateKey() {
        let app = XCUIApplication()
        ImportWalletFlowLauncher(app)
            .start()
        
        ImportWalletTypeSceneRobot(app)
            .tapEthereum()
        
        ImportWalletSceneRobot(app)
            .checkTitle(contains: "Ethereum")
            .checkSegmentedControl()
            .tapToPrivateKey()
            .insertPrivateKey()
            .tapContinue()
    }
    
    func testEthereumImportAddress() {
        let app = XCUIApplication()
        ImportWalletFlowLauncher(app)
            .start()
        
        ImportWalletTypeSceneRobot(app)
            .tapEthereum()
        
        ImportWalletSceneRobot(app)
            .tapToAddress()
            .insertAddress()
            .tapContinue()
    }
}
