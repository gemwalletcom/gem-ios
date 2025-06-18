// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Primitives
import Formatters

final class IntegerFormatterTests {

    @Test
    func testStringDouble() {
        let formatter = IntegerFormatter()
        #expect(formatter.string(12.12) == "12")
        #expect(formatter.string(21, symbol: "BTC") == "21 BTC")
    }
}
