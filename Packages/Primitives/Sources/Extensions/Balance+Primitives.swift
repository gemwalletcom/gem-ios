// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Balance {
    public var total: BigInt {
        available + frozen + locked + staked + pending + rewards
    }
    
    public static let zero: Balance = Balance(available: BigInt.zero)

    public func total(_ includeStakedBalance: Bool) -> BigInt {
        return available + frozen + locked + pending + rewards + (includeStakedBalance ? staked : BigInt(0))
    }
}
