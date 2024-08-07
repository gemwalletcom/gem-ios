// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension ChainType {
    public var feeUnitType: FeeUnitType? {
        switch self {
        case .bitcoin:
            BitcoinChain(rawValue: rawValue)?.feeUnitType
        case .ethereum, .aptos, .solana, .cosmos, .ton, .tron, .sui, .xrp, .near:
            nil
        }
    }

}
