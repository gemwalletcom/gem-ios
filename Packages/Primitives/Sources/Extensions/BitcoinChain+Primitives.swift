// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension BitcoinChain {
    public var chain: Chain {
        switch self {
        case .bitcoin: return .bitcoin
        case .litecoin: return .litecoin
        case .doge: return .doge
        case .bitcoinCash: return .bitcoinCash
        }
    }
}
