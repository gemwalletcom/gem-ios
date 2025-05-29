// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import XCTest

final class SelectAssetSceneRobot: Robot {
    private lazy var btcToggle = app.switches[AccessibilityIdentifier.IdentifiableView.key("Bitcoin").id]
    private lazy var ethToggle = app.switches[AccessibilityIdentifier.IdentifiableView.key("Ethereum").id]
    
    @discardableResult
    func checkManageAssetScene() -> Self {
        checkSearchExist()
        assert(btcToggle, [.exists, .isHittable, .isOn])
        assert(ethToggle, [.exists, .isHittable, .isOn])
        
        return self
    }
    
    @discardableResult
    func checkSearchExist() -> Self {
        assert(searchField, [.exists])
        
        return self
    }
    
    @discardableResult
    func checkTags(_ tags: [AssetTag]) -> Self {
        tags.forEach {
            assert(tagView($0), [.exists, .isHittable])
        }
        
        return self
    }
    
    @discardableResult
    func disableAssets() -> Self {
        tap(btcToggle)
        tap(ethToggle)
        
        assert(btcToggle, [.exists, .isHittable, .isOff])
        assert(ethToggle, [.exists, .isHittable, .isOff])
        
        return self
    }
    
    @discardableResult
    func enableAssets() -> Self {
        tap(btcToggle)
        tap(ethToggle)
        
        assert(btcToggle, [.exists, .isHittable, .isOn])
        assert(ethToggle, [.exists, .isHittable, .isOn])
        
        return self
    }

    // MARK: - Private methods
    
    private func tagView(_ tag: AssetTag) -> XCUIElement {
        app.buttons[AccessibilityIdentifier.IdentifiableView.key(tag.rawValue).id]
    }
}
