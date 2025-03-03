// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt

final class BigInt_PrimitivesTests {
    @Test
    func testIncreaseByBPS() {
        #expect(BigInt(1).increase(by: 1_000) == BigInt(1))
        #expect(BigInt(100).increase(by: 1_000) == BigInt(110))
        #expect(BigInt(100).increase(by: 1_100) == BigInt(111))
        #expect(BigInt(100).increase(by: 1_550) == BigInt(115))
        #expect(BigInt(100).increase(by: 0) == BigInt(100))
        #expect(BigInt(100).increase(by: 10_000) == BigInt(200))
        #expect(BigInt(1_000_000).increase(by: 5_000) == BigInt(1_500_000))
    }
    
    @Test
    func testMultiplyByBPS() {
        #expect(BigInt(100).multiply(by: 10_000) == BigInt(100))
        #expect(BigInt(100).multiply(by: 5_000) == BigInt(50))
        #expect(BigInt(100).multiply(by: 2_500) == BigInt(25))
        #expect(BigInt(200).multiply(by: 1_000) == BigInt(20))
        #expect(BigInt(1000).multiply(by: 7_500) == BigInt(750))
    }
}
