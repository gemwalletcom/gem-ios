// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives
import BigInt

final class BigInt_PrimitivesTests: XCTestCase {

    func testIncrease() {
        XCTAssertEqual(BigInt(1).increase(byPercentage: 10), BigInt(1))
        XCTAssertEqual(BigInt(100).increase(byPercentage: 10), BigInt(110))
        XCTAssertEqual(BigInt(100).increase(byPercentage: 11), BigInt(111))
        XCTAssertEqual(BigInt(100).increase(byPercentage: 15.5), BigInt(116))
    }
}
