// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Transfer
import BigInt

@MainActor
struct FeeUnitViewModelTests {

    @Test func testValue() async {
        #expect(FeeUnitViewModel(unit: FeeUnit(type: .satB, value: BigInt(1000))).value == "4 sat/B")
        #expect(FeeUnitViewModel(unit: FeeUnit(type: .satVb, value: BigInt(100000))).value == "100 sat/vB")
    }
}
