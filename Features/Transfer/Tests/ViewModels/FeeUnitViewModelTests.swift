// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Transfer
import BigInt
import Primitives

@MainActor
struct FeeUnitViewModelTests {

    @Test func testValue() async {
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000))
            ).value == "100,00 sat/vB"
        )

        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000_123))
            ).value == "100000,12 sat/vB"
        )

        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(100_000))
            ).value == "0,0001 gwei"
        )

        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789))
            ).value == "0,12 gwei"
        )

        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789_012))
            ).value == "123,46 gwei"
        )
    }
}
