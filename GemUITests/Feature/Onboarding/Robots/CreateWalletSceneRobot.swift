// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import KeystoreTestKit

final class CreateWalletSceneRobot: Robot {
    
    @discardableResult
    func checkScreen() -> Self {
        LocalKeystore.words.forEach {
            assert(app.staticTexts[$0], [.exists])
        }
        assert(stateButton, [.exists, .isHittable])
        assert(app.buttons["Copy"], [.exists, .isHittable])
        
        return self
    }
    
    @discardableResult
    func tapContinueButton() -> VerifyPhraseWalletSceneRobot {
        tap(stateButton)
        
        return VerifyPhraseWalletSceneRobot(app)
    }
}
