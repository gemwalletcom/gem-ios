// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

enum BlockchainMethod: Sendable {
    case ethereum(WalletConnectBlockchainEthereumMethods)
    case solana(WalletConnectBlockchainSolanaMethods)
    
    var ethereum: WalletConnectBlockchainEthereumMethods? {
        switch self {
        case .ethereum(let method): method
        case .solana: nil
        }
    }
    
    var solana: WalletConnectBlockchainSolanaMethods? {
        switch self {
        case .ethereum: nil
        case .solana(let method): method
        }
    }
}
