// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

// TODO: - evm chain config similar to bitcoin ocnfig ?

public struct EVMHistoryRewardPercentiles: Sendable {
    public let slow: Int
    public let normal: Int
    public let fast: Int

    var all: [Int] {
        [slow, normal, fast]
    }

    public init(slow: Int = 25, normal: Int = 50, high: Int = 75) {
        self.slow = slow
        self.normal = normal
        self.fast = high
    }
}
