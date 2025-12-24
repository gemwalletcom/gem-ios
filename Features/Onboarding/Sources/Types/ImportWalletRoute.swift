// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum ImportWalletRoute {
    case importWalletType
    case selectImage(wallet: Wallet)
    case walletProfile(wallet: Wallet)
}
