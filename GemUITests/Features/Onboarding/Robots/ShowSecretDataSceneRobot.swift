// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore

final class ShowSecretDataSceneRobot: Robot {
    
    @discardableResult
    func checkWordsScene() -> Self {
        LocalKeystore.words.forEach {
            assert(app.staticTexts[$0], [.exists])
        }
        
        return self
    }
    
    @discardableResult
    func checkPrivateKeyScene() -> Self {
        assert(app.staticTexts[LocalKeystore.privateKey], [.exists])
        
        return self
    }
    
    @discardableResult
    func checkCopyButton() -> Self {
        assert(app.buttons["Copy"], [.exists, .isHittable])
        
        return self
    }
}
