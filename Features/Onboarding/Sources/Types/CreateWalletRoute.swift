// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum CreateWalletRoute {
    case securityReminder
    case createWallet
    case verifyPhrase(words: [String])
    case selectImage(wallet: Wallet)
}
