// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum CreateWalletRoute {
    case securityReminder
    case createWallet
    case verifyPhrase(secretData: SecretData)
    case walletProfile(wallet: Wallet)
}
