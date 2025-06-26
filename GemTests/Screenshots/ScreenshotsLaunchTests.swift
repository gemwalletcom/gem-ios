// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives

@MainActor
final class ScreenshotsLaunchTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor func testScreenshots() throws {
        // Take a screenshot of an app's first window.
        let app = XCUIApplication()
        
        if let path = ProcessInfo.processInfo.environment["SCREENSHOTS_PATH"] {
          app.launchEnvironment["SCREENSHOTS_PATH"] = path
        }
        
        app.launch()
        let snapshoter = Snapshoter(app: app)

        let collectionViewsQuery = app.collectionViews

        // import wallet if not already
        if app.buttons.containing(.button, identifier: "welcome_import").count > 0 {

            app.buttons.element(boundBy: 1).tap()

            collectionViewsQuery.buttons.element(matching: .button, identifier: "multicoin").tap()
            
            let secretPhrase = ProcessInfo.processInfo.environment["SCREENSHOTS_SECRET_PHRASE"]!
            collectionViewsQuery.textViews.element(matching: .textView, identifier: "phrase")
                .typeText(secretPhrase)

            app.buttons.element(matching: .button, identifier: "import_wallet").tap()
        }

        sleep(4)

        try snapshoter.snap("secure")

        collectionViewsQuery.staticTexts["Solana"].tap()

        try snapshoter.snap("private")

        collectionViewsQuery.buttons.element(matching: .button, identifier: "buy").tap()

        sleep(4)

        try snapshoter.snap("buy")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        collectionViewsQuery.buttons.element(matching: .button, identifier: "swap").tap()
        
        let fromTextField = app.textFields.element(boundBy: 0)
        fromTextField.tap()
        fromTextField.typeText("1\n")
        
        sleep(4)
        
        try snapshoter.snap("trade")
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        collectionViewsQuery.buttons.element(matching: .button, identifier: "price").tap()

        sleep(1)

        try snapshoter.snap("track")

        app.navigationBars.buttons.element(boundBy: 0).tap()

        collectionViewsQuery.buttons.element(matching: .button, identifier: "stake").tap()
        
        sleep(5)

        try snapshoter.snap("earn")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        collectionViewsQuery.buttons.element(matching: .button, identifier: "manage").tap()

        try snapshoter.snap("manage")

        app.navigationBars.buttons.element(boundBy: 0).tap()

        sleep(1)
        
        if app.tabBars.element.exists {
            app.tabBars.buttons.element(boundBy: 2).tap()
        } else {
            app.buttons.element(boundBy: 2).tap()
        }

        try snapshoter.snap("activity")

        if app.tabBars.element.exists {
            app.tabBars.buttons.element(boundBy: 3).tap()
        } else {
            app.buttons.element(boundBy: 3).tap()
        }
        
        try snapshoter.snap("control")
    }
}

@MainActor
struct Snapshoter {

    let app: XCUIApplication
    let timeout: UInt32 = 1

    func snap(_ name: String) throws {

        sleep(timeout)

        let screenshotData = app.windows.firstMatch.screenshot().pngRepresentation

        let path = ProcessInfo.processInfo.environment["SCREENSHOTS_PATH"]!
        let directoryPath = "\(path)/\(Locale.current.appstoreLanguageIdentifier())"
        
        let fileURL = URL(fileURLWithPath: "\(directoryPath)/\(UIDevice.current.model.lowercased())_\(name).png")

        
        // Create the directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryPath) {
            try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        }

        // Save the screenshot
        try screenshotData.write(to: fileURL)
    }
}
