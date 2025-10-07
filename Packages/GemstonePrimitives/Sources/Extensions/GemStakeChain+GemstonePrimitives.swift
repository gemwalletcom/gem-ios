// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import enum Gemstone.GemStakeChain
import Primitives

public extension StakeChain {
    func map() -> GemStakeChain {
        switch self {
        case .cosmos: .cosmos
        case .osmosis: .osmosis
        case .injective: .injective
        case .sei: .sei
        case .celestia: .celestia
        case .ethereum: .ethereum
        case .solana: .solana
        case .sui: .sui
        case .smartChain: .smartChain
        case .tron: .tron
        case .hyperCore: .hyperCore
        }
    }
}
