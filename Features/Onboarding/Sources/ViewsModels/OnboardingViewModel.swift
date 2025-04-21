// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import WalletService

public struct OnboardingViewModel {
    var title: String { Localized.Welcome.title }
    var createWalletTitle: String { Localized.Wallet.createNewWallet }
    var importWalletTitle: String { Localized.Wallet.importExistingWallet }

    let walletService: WalletService

    public init(walletService: WalletService) {
        self.walletService = walletService
    }
}
