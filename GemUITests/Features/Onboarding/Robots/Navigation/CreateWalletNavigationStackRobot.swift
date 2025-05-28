// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class CreateWalletNavigationStackRobot: Robot {
    func startCreateFirstWalletFlow() {
        start(scenario: .createFirstWallet)
    }
    
    func startCreateWalletFlow() {
        start(scenario: .createWallet)
    }
}
