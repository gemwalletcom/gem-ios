// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import KeystoreTestKit

final class VerifyPhraseWalletSceneRobot: Robot {
    
    @discardableResult
    func checkScene() -> Self {
        assert(stateButton, [.exists, .isNotEnabled])
        
        return self
    }
    
    @discardableResult
    func verifyPhrase() -> Self {
        LocalKeystore.words.forEach {
            tap(app.buttons[$0])
        }
        assert(stateButton, [.isEnabled])
        
        return self
    }
    
    func tapContinueButton() {
        tap(stateButton)
    }
}
