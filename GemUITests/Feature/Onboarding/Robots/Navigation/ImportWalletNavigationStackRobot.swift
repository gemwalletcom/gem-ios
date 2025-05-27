// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class ImportWalletNavigationStackRobot: Robot {
    func startImportWalletFlow() {
        start(scenario: .importWallet)
    }
}
