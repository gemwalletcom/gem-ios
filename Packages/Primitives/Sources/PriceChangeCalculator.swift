// Copyright (c). Gem Wallet. All rights reserved.

public enum PriceChangeCalculatorType {
    case percentage(from: Double, to: Double)
    case amount(percentage: Double, value: Double)
}

public struct PriceChangeCalculator {
    public static func calculate(_ type: PriceChangeCalculatorType) -> Double {
        switch type {
        case .percentage(let from, let to):
            return from == 0 ? 0 : (to - from) / from * 100
        case .amount(let percentage, let value):
            let denominator = 100 + percentage
            return denominator == 0 ? 0 : value * percentage / denominator
        }
    }
}
 
