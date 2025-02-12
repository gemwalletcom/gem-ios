// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum UpdateBalanceType {
    case coin(UpdateCoinBalance)
    case token(UpdateTokenBalance)
    case stake(UpdateStakeBalance)
}

public struct UpdateCoinBalance {
    public let available: UpdateBalanceValue
    public let reserved: UpdateBalanceValue
    
    public init(
        available: UpdateBalanceValue,
        reserved: UpdateBalanceValue
    ) {
        self.available = available
        self.reserved = reserved
    }
}

public struct UpdateTokenBalance {
    public let available: UpdateBalanceValue
    
    public init(available: UpdateBalanceValue) {
        self.available = available
    }
}

public struct UpdateStakeBalance {
    public let staked: UpdateBalanceValue
    public let pending: UpdateBalanceValue
    public let frozen: UpdateBalanceValue
    public let locked: UpdateBalanceValue
    public let rewards: UpdateBalanceValue
    
    public init(
        staked: UpdateBalanceValue,
        pending: UpdateBalanceValue,
        frozen: UpdateBalanceValue,
        locked: UpdateBalanceValue,
        rewards: UpdateBalanceValue
    ) {
        self.staked = staked
        self.pending = pending
        self.frozen = frozen
        self.locked = locked
        self.rewards = rewards
    }
}
