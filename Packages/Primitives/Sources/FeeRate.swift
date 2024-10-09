// Copyright (c). Gem Wallet. All rights reserved.

import BigInt

public struct FeeRate: Identifiable, Equatable, Hashable, Sendable {
    public let priority: FeePriority
    public let value: BigInt

    public var id: String { priority.id }

    public init(priority: FeePriority, rate: BigInt) {
        self.priority = priority
        self.value = rate
    }
}
