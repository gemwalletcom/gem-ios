// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCUIAutomation
import Components
import Primitives

final class ImportWalletTypeSceneRobot: Robot {
    private lazy var multicoin: XCUIElement = app.buttons[AccessibilityIdentifier.Onboarding.multicoinNavigationLink.id]
    private lazy var ethereum: XCUIElement = app.buttons[AccessibilityIdentifier.Onboarding.chainNavigationLink(Chain.ethereum.rawValue).id]
    
    @discardableResult
    func checkScreen() -> Self {
        assert(searchField, [.exists, .isHittable])
        assert(multicoin, [.exists, .isHittable])
        assert(ethereum, [.exists, .isHittable])
        
        return self
    }
    
    @discardableResult
    func checkSearchEmpty() -> Self {
        tap(searchField)
        searchField.typeText("Abrakadabra")
        assert(app.staticTexts["No Results Found"], [.exists])
        assert(multicoin, [.exists])
        tap(cancelSearchButton)
        
        return self
    }
    
    @discardableResult
    func checkSearchNotEmpty() -> Self {
        tap(searchField)
        searchField.typeText(Chain.arbitrum.rawValue)
        assert(app.buttons[AccessibilityIdentifier.Onboarding.chainNavigationLink(Chain.arbitrum.rawValue).id], [.exists])
        tap(cancelButton)
        
        return self
    }
    
    @discardableResult
    func tapMulticoin() -> ImportWalletSceneRobot {
        tap(multicoin)
        
        return ImportWalletSceneRobot(app)
    }
    
    @discardableResult
    func tapEthereum() -> ImportWalletSceneRobot {
        tap(ethereum)
        
        return ImportWalletSceneRobot(app)
    }
}
