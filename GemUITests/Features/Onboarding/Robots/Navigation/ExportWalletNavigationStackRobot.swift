// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class ExportWalletNavigationStackRobot: Robot {
    func startExportWordsFlow() {
        start(scenario: .exportWords)
    }
    
    func startExportPrivateKeyFlow() {
        start(scenario: .exportPrivateKey)
    }
}
