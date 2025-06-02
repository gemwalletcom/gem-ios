// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest

@MainActor
final class AssetSceneUITests: XCTestCase {
    
    func testHeaderButtons() {
        let app = XCUIApplication()
        WalletNavigationStack(app)
            .startAssetScene()
        
        AssetSceneRobot(app)
            .checkScene()
            .tapSendButton()
            .tapReceiveButton()
            .tapBuyButton()
            .tapSwapButton()
    }
}
