// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest
import Components
import PrimitivesComponents

final class AssetSceneRobot: Robot {
    
    private lazy var headerButtons: [XCUIElement] = [
        headerButton(.send),
        headerButton(.receive),
        headerButton(.buy),
        headerButton(.swap)
    ]
    
    @discardableResult
    func checkScene() -> Self {
        headerButtons.forEach {
            assert($0, [.exists, .isHittable])
        }
        
        return self
    }
    
    @discardableResult
    func tapSendButton() -> Self {
        tap(headerButton(.send))
        checkTitle(contains: "Recipient")
        tap(doneButton)
        
        return self
    }
    
    @discardableResult
    func tapReceiveButton() -> Self {
        tap(headerButton(.receive))
        checkTitle(contains: "Receive ETH")
        tap(doneButton)
        
        return self
    }
    
    @discardableResult
    func tapBuyButton() -> Self {
        tap(headerButton(.buy))
        tap(doneButton)
        
        return self
    }
    
    @discardableResult
    func tapSwapButton() -> Self {
        tap(headerButton(.swap))
        checkTitle(contains: "Swap")
        tap(app.navigationBars.buttons[AccessibilityIdentifier.doneButton.id])
        
        return self
    }
    
    // MARK: - Private methods
    
    private func headerButton(_ button: HeaderButtonType) -> XCUIElement {
        app.buttons[AccessibilityIdentifier.IdentifiableView.key(button.id).id]
    }
}
