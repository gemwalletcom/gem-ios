// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public enum PerpetualMinimumCalculator {
    // Hyperliquid requires minimum $10 notional value (size × price)
    // Size is rounded to szDecimals, so we must account for rounding
    public static func calculateMinimumUSDC(
        price: Double,
        szDecimals: Int,
        leverage: UInt8
    ) -> BigInt {
        let sizeMultiplier = pow(10.0, Double(szDecimals))
        let roundedSize = ceil((10.0 / price) * sizeMultiplier) / sizeMultiplier
        let minUSDC = ceil((roundedSize * price / Double(leverage)) * 100) / 100

        return BigInt(minUSDC * 1_000_000)
    }
}
