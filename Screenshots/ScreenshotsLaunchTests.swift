// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

final class ScreenshotsLaunchTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor func testLaunch() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        let collectionViewsQuery = app.collectionViews

        // import wallet if not already
        if app.buttons.containing(.button, identifier: "welcome_import").count > 0 {
            
            app.buttons.element(boundBy: 1).tap()
            
            collectionViewsQuery.buttons.element(matching: .button, identifier: "multicoin").tap()
            
            //let secretPhrase = UserDefaults.standard.string(forKey: "secretPhrase")!.split(separator: "_").joined()
            collectionViewsQuery.textViews.element(matching: .textView, identifier: "phrase")
                //.typeText(secretPhrase)
                //TODO: Move into envs or pass from fastlane
                .typeText("couple win rather shield legend later label half dizzy link tattoo tribe")
            
            app.buttons.element(matching: .button, identifier: "import_wallet").tap()
        }
        
        sleep(4)
        
        snapshot("1_Secure")
        
        collectionViewsQuery.staticTexts["Ethereum"].tap()
        
        snapshot("2_Private")
        
//        market
//        collectionViewsQuery.buttons.element(matching: .button, identifier: "price").tap()
//        sleep(1)
//        snapshot("4_Market")
//        app.navigationBars.buttons.element(boundBy: 0).tap()
//        sleep(1)
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        collectionViewsQuery.buttons.element(matching: .button, identifier: "manage").tap()
                
        snapshot("3_Powerful")
        
//        transactions
//        app.buttons.element(matching: .button, identifier: "cancel").tap()
//        sleep(1)
//        app.buttons.element(matching: .button, identifier: "transactions").tap()
//        sleep(1)
//        snapshot("5_Transactions")
        
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
