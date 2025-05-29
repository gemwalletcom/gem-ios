// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest

@MainActor
final class SelectAssetSceneUITests: XCTestCase {
    
    func testManageScenario() {
        let app = XCUIApplication()
        SelectAssetSceneNavigationStackRobot(app)
            .startManage()
            .checkBackButton(title: "Done")
            .checkFilterButton()
            .checkPlusButton()
        
        SelectAssetSceneRobot(app)
            .checkManageAssetScene()
            .checkTitle(contains: "Manage Token List")
            .checkTags([.stablecoins, .trending])
            .disableAssets()
            .enableAssets()
    }
}
