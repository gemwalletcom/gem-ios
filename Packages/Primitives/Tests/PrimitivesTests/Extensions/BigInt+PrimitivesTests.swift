// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt

final class BigInt_PrimitivesTests {
    @Test
    func testIncreaseByPercent() {
        #expect(BigInt(1).increase(byPercent: 1) == BigInt(1))
        #expect(BigInt(100).increase(byPercent: 1) == BigInt(101))
        #expect(BigInt(100).increase(byPercent: 11) == BigInt(111))
        #expect(BigInt(100).increase(byPercent: 15) == BigInt(115))
        #expect(BigInt(100).increase(byPercent: 0) == BigInt(100))
        #expect(BigInt(100).increase(byPercent: 100) == BigInt(200))
        #expect(BigInt(1_000_000).increase(byPercent: 500) == BigInt(6000000))
    }
    
    @Test
    func testMultiplyByPercent() {
        #expect(BigInt(100).multiply(byPercent: 10) == BigInt(10))
        #expect(BigInt(100).multiply(byPercent: 5) == BigInt(5))
        #expect(BigInt(1000).multiply(byPercent: 75) == BigInt(750))
    }
}
