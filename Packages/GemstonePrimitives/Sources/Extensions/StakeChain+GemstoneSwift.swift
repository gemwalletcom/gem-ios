// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import class Gemstone.Config

extension StakeChain {
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
