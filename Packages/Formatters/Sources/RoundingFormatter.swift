// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct RoundingFormatter: Sendable {

    public init() {}

    public func roundedValues<T: BinaryFloatingPoint>(for value: T, byPercent: T) -> [T] {
        guard value >= 0.01, byPercent > 0 else { return [] }

        let lowerTarget = value * (1 - byPercent / 100)
        let upperTarget = value * (1 + byPercent / 100)
        let step = step(for: lowerTarget)
        let upperRounding: FloatingPointRoundingRule = step > 1 ? .toNearestOrAwayFromZero : .up
        let lower = (lowerTarget / step).rounded(.down) * step
        let upper = (upperTarget / step).rounded(upperRounding) * step

        return [lower, upper]
    }

    private func step<T: BinaryFloatingPoint>(for value: T) -> T {
        switch value {
        case ..<1: 0.01
        case ..<100: 1
        case ..<500: 10
        case ..<10000: 50
        default: 1000
        }
    }
}
