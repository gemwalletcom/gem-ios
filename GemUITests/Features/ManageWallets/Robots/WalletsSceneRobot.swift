// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest

@testable import ManageWallets

final class WalletsSceneRobot: Robot {
    
    private lazy var createWalletButton: XCUIElement = app.buttons[ManageWalletsAccessibilityIdentifier.manageWalletsCreateButton.id]
    private lazy var importWalletButton: XCUIElement = app.buttons[ManageWalletsAccessibilityIdentifier.manageWalletsImportButton.id]
    
    func start() -> Self {
        start(scenario: .walletsList)
        
        return self
    }
    
    @discardableResult
    func checkScene() -> Self {
        assert(createWalletButton, [.exists, .isHittable])
        assert(importWalletButton, [.exists, .isHittable])
        
        return self
    }
}
