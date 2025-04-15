// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import ManageWalletService

public struct OnboardingViewModel {
    var title: String { Localized.Welcome.title }
    var createWalletTitle: String { Localized.Wallet.createNewWallet }
    var importWalletTitle: String { Localized.Wallet.importExistingWallet }

    let manageWalletService: ManageWalletService

    public init(manageWalletService: ManageWalletService) {
        self.manageWalletService = manageWalletService
    }
}
