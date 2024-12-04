// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import BigInt
import Primitives
@testable import Transfer

@MainActor
struct FeeUnitViewModelTests {
    let formatter = CurrencyFormatter()
    let usFormmatter = CurrencyFormatter(locale: .US)

    @Test func testValue() async {
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000)),
                formatter: formatter
            ).value == "100,00 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000_123)),
                formatter: formatter
            ).value == "100000,12 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satB, value: BigInt(1000)),
                formatter: formatter
            ).value == "4,00 sat/B"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(100_000)),
                formatter: formatter
            ).value == "0,0001 gwei"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789)),
                formatter: formatter
            ).value == "0,12 gwei"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789_012)),
                formatter: formatter
            ).value == "123,46 gwei"
        )
    }

    @Test func testValueUS() async {
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000)),
                formatter: usFormmatter
            ).value == "100.00 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satB, value: BigInt(1000)),
                formatter: usFormmatter
            ).value == "4.00 sat/B"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000_123)),
                formatter: usFormmatter
            ).value == "100,000.12 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(100_000)),
                formatter: usFormmatter
            ).value == "0.0001 gwei"
        )

        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789)),
                formatter: usFormmatter
            ).value == "0.12 gwei"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789_012)),
                formatter: usFormmatter
            ).value == "123.46 gwei"
        )
    }
}
