// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct FeePriorityValue {
    public let priority: FeePriority
    public let value: BigInt
    
    public init(priority: FeePriority, value: BigInt) {
        self.priority = priority
        self.value = value
    }
}
