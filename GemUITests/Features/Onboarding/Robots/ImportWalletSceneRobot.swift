// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import XCTest
import Keystore
import KeystoreTestKit

@testable import Onboarding

final class ImportWalletSceneRobot: Robot {
    private lazy var floatTextField: XCUIElement = app.textFields[AccessibilityIdentifier.floatTextField.id]
    private lazy var phraseTextField: XCUIElement = app.textFields[OnboardingAccessibilityIdentifier.phraseTextField.id]
    
    @discardableResult
    func checkScene() -> Self {
        assert(stateButton, [.exists])
        assert(floatTextField, [.exists, .isHittable])
        assert(phraseTextField, [.exists, .isHittable])
        
        return self
    }
    
    @discardableResult
    func checkWalletName(_ name: String) -> Self {
        assert(floatTextField, [.value(name)])
        
        return self
    }
    
    @discardableResult
    func checkSegmentedControl() -> Self {
        assert(app.segmentedControls.buttons["Phrase"], [.exists, .isHittable])
        assert(app.segmentedControls.buttons["Private Key"], [.exists, .isHittable])
        assert(app.segmentedControls.buttons["Address"], [.exists, .isHittable])
        
        return self
    }
    
    @discardableResult
    func tapToPrivateKey() -> Self {
        tap(app.segmentedControls.buttons[OnboardingAccessibilityIdentifier.walletImportType("Private Key").id])
        
        return self
    }
    
    @discardableResult
    func tapToAddress() -> Self {
        tap(app.segmentedControls.buttons[OnboardingAccessibilityIdentifier.walletImportType("Address").id])
        
        return self
    }
    
    @discardableResult
    func renameWallet() -> Self {
        tap(floatTextField)
        tap(app.buttons[AccessibilityIdentifier.xCircleCleanButton.id])
        floatTextField.typeText("New Wallet")

        return self
    }
    
    @discardableResult
    func insertCorrectPhrase() -> Self {
        tap(phraseTextField)
        phraseTextField.clearAndEnterText(text: LocalKeystore.words.joined(separator: " "))
        
        return self
    }
    
    @discardableResult
    func insertIncorrectPhrase() -> Self {
        tap(phraseTextField)
        phraseTextField.typeText("Abrakadaabra")
        tap(stateButton)
        assert(alert, [.exists])
        tap(app.alerts.buttons["OK"])
        
        return self
    }
    
    @discardableResult
    func insertPrivateKey() -> Self {
        tap(phraseTextField)
        phraseTextField.typeText(LocalKeystore.privateKey)
        
        return self
    }
    
    @discardableResult
    func insertAddress() -> Self {
        tap(phraseTextField)
        phraseTextField.typeText(LocalKeystore.address)
        
        return self
    }

    func tapContinueButton() {
        tap(stateButton)
        assert(alert, [.doesNotExist])
    }
}
