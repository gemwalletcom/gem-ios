// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct UpdateBalanceValue: Sendable {
    public let value: String
    public let amount: Double

    public static let zero = UpdateBalanceValue(value: "0", amount: 0)

    public init(value: String, amount: Double) {
        self.value = value
        self.amount = amount
    }
}
