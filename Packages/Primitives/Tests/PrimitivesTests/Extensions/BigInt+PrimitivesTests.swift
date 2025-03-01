// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt

final class BigInt_PrimitivesTests {
    @Test
    func testIncrease() {
        #expect(BigInt(1).increase(byPercentage: 10) == BigInt(1))
        #expect(BigInt(100).increase(byPercentage: 10) == BigInt(110))
        #expect(BigInt(100).increase(byPercentage: 11) == BigInt(111))
        #expect(BigInt(100).increase(byPercentage: 15.5) == BigInt(116))
    }
    
    @Test
    func testMultiply() {
        #expect(BigInt(100).multiply(byPercentage: 1.0) == BigInt(100))
        #expect(BigInt(100).multiply(byPercentage: 0.5) == BigInt(50))
        #expect(BigInt(100).multiply(byPercentage: 0.25) == BigInt(25))
        #expect(BigInt(200).multiply(byPercentage: 0.1) == BigInt(20))
        #expect(BigInt(1000).multiply(byPercentage: 0.75) == BigInt(750))
    }
}
