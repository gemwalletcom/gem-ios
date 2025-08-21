// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension BitcoinChain {
    public init(id: String) throws {
        if let chain = BitcoinChain(rawValue: id) {
            self = chain
        } else {
            throw AnyError("invalid chain id: \(id)")
        }
    }
    public var chain: Chain {
        switch self {
        case .bitcoin: return .bitcoin
        case .litecoin: return .litecoin
        case .doge: return .doge
        case .bitcoinCash: return .bitcoinCash
        }
    }
}
