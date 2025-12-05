// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone
import BigInt

extension StakeChain {
    public func map() -> GemStakeChain {
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
        case .aptos: .aptos
        case .hyperCore: .hyperCore
        case .monad: .monad
        }
    }
    
    public var lockTime: TimeInterval {
        Double(Config.shared.getStakeConfig(chain: rawValue).timeLock)
    }

    public var minAmount: BigInt {
        BigInt(Config.shared.getStakeConfig(chain: rawValue).minAmount)
    }

    public var canChangeAmountOnUnstake: Bool {
        Config.shared.getStakeConfig(chain: rawValue).changeAmountOnUnstake
    }
    
    public var supportRedelegate: Bool {
        Config.shared.getStakeConfig(chain: rawValue).canRedelegate
    }
    
    public var supportWidthdraw: Bool {
        Config.shared.getStakeConfig(chain: rawValue).canWithdraw
    }
    
    public var supportClaimRewards: Bool {
        Config.shared.getStakeConfig(chain: rawValue).canClaimRewards
    }
}
