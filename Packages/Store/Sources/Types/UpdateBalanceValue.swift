// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct UpdateBalanceValue {
    public let value: String
    public let amount: Double
    
    public init(value: String, amount: Double) {
        self.value = value
        self.amount = amount
    }
}
