// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class ImportWalletFlowLauncher: Robot {
    
    @discardableResult
    func start() -> Self {
        start(scenario: .importWallet)
    }
}
