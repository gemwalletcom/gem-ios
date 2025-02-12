// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Keystore

public struct OnboardingViewModel {
    var title: String { Localized.Welcome.title }
    var createWalletTitle: String { Localized.Wallet.createNewWallet }
    var importWalletTitle: String { Localized.Wallet.importExistingWallet }

    let keystore: any Keystore

    public init(keystore: any Keystore) {
        self.keystore = keystore
    }
}
