// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum BlockchainMethod: Sendable {
    case ethereum(WalletConnectEthereumMethods)
    case solana(WalletConnectSolanaMethods)
    case sui(WalletConnectSuiMethods)
}
