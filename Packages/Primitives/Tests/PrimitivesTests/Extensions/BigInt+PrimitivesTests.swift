// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt

struct BigInt_PrimitivesTests {
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
    func testDecreaseByPercent() {
        #expect(BigInt(100).decrease(byPercent: 1) == BigInt(99))
        #expect(BigInt(100).decrease(byPercent: 10) == BigInt(90))
        #expect(BigInt(100).decrease(byPercent: 50) == BigInt(50))
        #expect(BigInt(1000).decrease(byPercent: 25) == BigInt(750))
        #expect(BigInt(100).decrease(byPercent: 0) == BigInt(100))
    }
    
    @Test
    func testMultiplyByPercent() {
        #expect(BigInt(100).multiply(byPercent: 10) == BigInt(10))
        #expect(BigInt(100).multiply(byPercent: 5) == BigInt(5))
        #expect(BigInt(1000).multiply(byPercent: 75) == BigInt(750))
    }
    
    @Test
    func testIsBetween() {
        #expect(BigInt(100).isBetween(99, and: 110))
        #expect(BigInt(100).isBetween(110, and: 99) == false)
        #expect(BigInt(100).isBetween(0, and: 10) == false)
        #expect(BigInt(0).isBetween(0, and: 1))
    }
    
    @Test
    func testFromString() throws {
        #expect(try BigInt.from(string: "111").description == "111")
        #expect(try BigInt.from(string: "0.1").description == "0")
    }
}
