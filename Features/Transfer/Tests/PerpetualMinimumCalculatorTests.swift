// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import BigInt
@testable import Transfer

struct PerpetualMinimumCalculatorTests {

    @Test
    func btc() {
        #expect(
            PerpetualMinimumCalculator.calculateMinimumUSDC(price: 100_000.0, szDecimals: 5, leverage: 1)
                == BigInt(10_000_000)
        )
    }

    @Test
    func eth() {
        #expect(
            PerpetualMinimumCalculator.calculateMinimumUSDC(price: 3_500.0, szDecimals: 4, leverage: 3)
                == BigInt(3_390_000)
        )
    }

    @Test
    func zec() {
        #expect(
            PerpetualMinimumCalculator.calculateMinimumUSDC(price: 487.0, szDecimals: 2, leverage: 1)
                == BigInt(14_610_000)
        )
    }

    @Test
    func sol() {
        #expect(
            PerpetualMinimumCalculator.calculateMinimumUSDC(price: 200.0, szDecimals: 1, leverage: 10)
                == BigInt(2_000_000)
        )
    }

    @Test
    func hpos() {
        #expect(
            PerpetualMinimumCalculator.calculateMinimumUSDC(price: 0.5, szDecimals: 0, leverage: 1)
                == BigInt(10_000_000)
        )
    }
}
