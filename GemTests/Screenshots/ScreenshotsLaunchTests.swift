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
        let locale = Locale.current.identifier
        do {
            try runScreenshots()
        } catch {
            XCTFail("❌ Screenshots failed for locale: \(locale) - \(error)")
        }
    }

    @MainActor private func runScreenshots() throws {
        let app = XCUIApplication()
        
        if let path = ProcessInfo.processInfo.environment["SCREENSHOTS_PATH"] {
          app.launchEnvironment["SCREENSHOTS_PATH"] = path
        }
        
        app.launch()
        let snapshoter = Snapshoter(app: app)

        let collectionViewsQuery = app.collectionViews

        sleep(4)

        try snapshoter.snap("secure")

        collectionViewsQuery.staticTexts["Solana"].tap()

        try snapshoter.snap("private")

        collectionViewsQuery.buttons.element(matching: .button, identifier: "buy_button").tap()

        sleep(4)

        try snapshoter.snap("buy")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        collectionViewsQuery.buttons.element(matching: .button, identifier: "swap_button").tap()
        
        let fromTextField = app.textFields.element(boundBy: 0)
        fromTextField.tap()
        fromTextField.typeText("0.2\n")
        
        sleep(4)
        
        try snapshoter.snap("trade")
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        collectionViewsQuery.buttons.element(matching: .button, identifier: "price").tap()

        sleep(1)

        try snapshoter.snap("track")

        app.navigationBars.buttons.element(boundBy: 0).tap()

        collectionViewsQuery.buttons.element(matching: .button, identifier: "stake").tap()
        
        sleep(3)

        try snapshoter.snap("earn")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        app.swipeUp()

        collectionViewsQuery.buttons.element(matching: .button, identifier: "manage").tap()

        try snapshoter.snap("manage")
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        if app.tabBars.element.exists {
            app.tabBars.buttons.element(boundBy: 1).tap()
        } else {
            app.buttons.element(boundBy: 1).tap()
        }
        
        sleep(3)
        
        try snapshoter.snap("nft")
        
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
        
        collectionViewsQuery.staticTexts["WalletConnect"].tap()
        
        try snapshoter.snap("connect")
    }
}

@MainActor
struct Snapshoter {

    let app: XCUIApplication
    let timeout: UInt32 = 1

    func snap(_ name: String) throws {

        sleep(timeout)

        let screenshotData = app.windows.firstMatch.screenshot().pngRepresentation

        let environmentPath = ProcessInfo.processInfo.environment["SCREENSHOTS_PATH"]
        guard let environmentPath else {
            throw AnyError("SCREENSHOTS_PATH is not set")
        }
        let path = environmentPath.isEmpty ? "\(NSHomeDirectory())/Documents/screenshots" : environmentPath
        
        let directoryPath = "\(path)/\(Locale.current.appstoreLanguageIdentifier())"
        
        let fileURL = URL(fileURLWithPath: "\(directoryPath)/\(UIDevice.current.model.lowercased())_\(name).png")
        
        // Create the directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryPath) {
            try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        }

        // Save the screenshot
        try screenshotData.write(to: fileURL)
        
        print("fileURL.path \(fileURL.path)")
    }
}
