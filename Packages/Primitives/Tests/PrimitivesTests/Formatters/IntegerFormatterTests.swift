// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import Primitives

final class IntegerFormatterTests: XCTestCase {

    func testStringDouble() {
        let formatter = IntegerFormatter()

        XCTAssertEqual(formatter.string(12.12), "12")
        XCTAssertEqual(formatter.string(21, symbol: "BTC"), "21 BTC")
    }
}
