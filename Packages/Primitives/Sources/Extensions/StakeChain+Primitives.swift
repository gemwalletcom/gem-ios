// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension StakeChain {
    public var canChangeAmountOnUnstake: Bool {
        switch self {
        case .cosmos,
            .osmosis,
            .injective,
            .sei,
            .celestia,
            .solana,
            .smartChain:
            true
        case .sui:
            false
        }
    }
    
    public var supportRedelegate: Bool {
        switch self {
        case .cosmos,
            .osmosis,
            .injective,
            .sei,
            .celestia,
            .smartChain:
            true
        case .sui,
            .solana:
            false
        }
    }
}

extension Chain {
    public var stakeChain: StakeChain? {
        StakeChain(rawValue: rawValue)
    }
}
