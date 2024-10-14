// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public struct IntroViewModel {
    public var title: String { Localized.Welcome.title }
    public var createWalletTitle: String { Localized.Wallet.createNewWallet }
    public var importWalletTitle: String { Localized.Wallet.importExistingWallet }

    public init() {
        
    }
}
