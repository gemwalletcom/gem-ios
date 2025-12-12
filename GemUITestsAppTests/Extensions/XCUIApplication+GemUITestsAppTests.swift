// Copyright (c). Gem Wallet. All rights reserved.

import XCTest

extension XCUIApplication {

    func logout(walletName: String = UITestKitConstants.defaultWalletName) {
        if OnboardingScene(app: self).isVisible == false {
            WalletScene(app: self)
                .tapWallet(walletName)
                .tapSettings()
                .tapDelete()
                .confirmDelete()
        }
    }
}
