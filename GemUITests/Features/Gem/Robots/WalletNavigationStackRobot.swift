// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class WalletNavigationStack: Robot {
    
    @discardableResult
    func startAssetScene() -> Self {
        start(scenario: .assetScene)
        tap(app.staticTexts["Ethereum"])
        
        return self
    }
}
