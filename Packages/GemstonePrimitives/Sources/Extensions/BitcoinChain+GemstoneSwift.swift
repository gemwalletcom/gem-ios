// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension BitcoinChain {
    public var minimumByteFee: Int {
        GemstoneConfig.shared.getBitcoinChainConfig(chain: chain.rawValue).minimumByteFee.asInt
    }
}
