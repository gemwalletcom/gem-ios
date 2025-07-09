// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Foundation

struct String_PrimitivesTests {
    @Test
    func trimmingZero() {
        #expect("0".trimLeadingZeros == "")
        #expect("01".trimLeadingZeros == "1")
        #expect("0110".trimLeadingZeros == "110")
    }
}
