// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import XCUIAutomation
import Keystore
import KeystoreTestKit

final class ImportWalletSceneRobot: Robot {
    private lazy var floatTextField: XCUIElement = app.textFields[AccessibilityIdentifier.Common.floatTextField.id]
    private lazy var phraseTextField: XCUIElement = app.textFields[AccessibilityIdentifier.Onboarding.phraseTextField.id]
    
    @discardableResult
    func checkScene() -> Self {
        assert(stateButton, [.exists])
        assert(floatTextField, [.value("Wallet #1")])
        assert(floatTextField, [.exists, .isHittable])
        assert(phraseTextField, [.exists, .isHittable])
        
        return self
    }
    
    @discardableResult
    func renameWallet() -> Self {
        tap(floatTextField)
        tap(app.buttons[AccessibilityIdentifier.Common.xCircleCleanButton.id])
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
        phraseTextField.typeText(.empty)
        
        return self
    }
    
    @discardableResult
    func tapContinue() -> Self {
        tap(stateButton)
        assert(alert, [.doesNotExist])
        
        return self
    }
}
