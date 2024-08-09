// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension BitcoinChain {
    public var chain: Chain {
        switch self {
        case .bitcoin: return .bitcoin
        case .litecoin: return .litecoin
        case .doge: return .doge
        }
    }

    public var feeUnitType: FeeUnitType? {
        .satVb
    }

    public var minimumByteFee: Int {
        switch self {
        case .bitcoin: 1 // 1 satoshi per byte for Bitcoin
        case .litecoin: 1 //  0.001 LTC per kB, converted to litoshis per byte
        case .doge: 1_000 // 1 DOGE per kB, converted to dogetoshis per byte
        }
    }
}
