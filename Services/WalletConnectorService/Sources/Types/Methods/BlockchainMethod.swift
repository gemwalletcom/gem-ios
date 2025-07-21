// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum BlockchainMethod: Sendable {
    case ethereum(EthereumMethods)
    case solana(SolanaMethods)
}
