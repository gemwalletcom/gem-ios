// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt

final class BigInt_PrimitivesTests {
    func testIncrease() {
        #expect(BigInt(1).increase(byPercentage: 10) == BigInt(1))
        #expect(BigInt(100).increase(byPercentage: 10) == BigInt(110))
        #expect(BigInt(100).increase(byPercentage: 11) == BigInt(111))
        #expect(BigInt(100).increase(byPercentage: 15.5) == BigInt(116))
    }
}
