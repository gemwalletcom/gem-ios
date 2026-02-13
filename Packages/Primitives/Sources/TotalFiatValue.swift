// Copyright (c). Gem Wallet. All rights reserved.

public struct TotalFiatValue: Sendable, Equatable {
    public let value: Double
    public let pnlAmount: Double
    public let pnlPercentage: Double

    public static let zero = TotalFiatValue(value: 0, pnlAmount: 0, pnlPercentage: 0)

    public init(value: Double, pnlAmount: Double, pnlPercentage: Double) {
        self.value = value
        self.pnlAmount = pnlAmount
        self.pnlPercentage = pnlPercentage
    }
}
