// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum BlockchainMethod: Sendable {
    case ethereum(WalletConnectEthereumMethods)
    case solana(WalletConnectSolanaMethods)
    
    var ethereum: WalletConnectEthereumMethods? {
        switch self {
        case .ethereum(let method): method
        case .solana: nil
        }
    }
    
    var solana: WalletConnectSolanaMethods? {
        switch self {
        case .ethereum: nil
        case .solana(let method): method
        }
    }
}
