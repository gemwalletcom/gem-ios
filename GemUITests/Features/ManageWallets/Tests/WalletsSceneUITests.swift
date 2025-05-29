// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest

@MainActor
final class WalletsSceneUITests: XCTestCase {
    
    func testWalletsScene() {
        let app = XCUIApplication()
        WalletsSceneRobot(app)
            .start()
            .checkScene()
            .checkTitle(contains: "Wallets")
            .checkBackButton(title: "Done")
    }
}
