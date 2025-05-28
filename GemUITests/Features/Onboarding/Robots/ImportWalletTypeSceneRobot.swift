// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest
import Components
import Primitives

@testable import Onboarding

final class ImportWalletTypeSceneRobot: Robot {
    private lazy var multicoin: XCUIElement = app.buttons[OnboardingAccessibilityIdentifier.multicoinNavigationLink.id]
    private lazy var ethereum: XCUIElement = app.buttons[OnboardingAccessibilityIdentifier.chainNavigationLink(Chain.ethereum.rawValue).id]
    
    @discardableResult
    func checkScene() -> Self {
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
        assert(app.buttons[OnboardingAccessibilityIdentifier.chainNavigationLink(Chain.arbitrum.rawValue).id], [.exists])
        tap(cancelButton)
        
        return self
    }

    func tapMulticoin() {
        tap(multicoin)
    }

    func tapEthereum() {
        tap(ethereum)
    }
}
