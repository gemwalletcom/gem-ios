// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import BigInt
import Primitives
import PrimitivesTestKit

@testable import Transfer

struct FeeUnitViewModelTests {
    let formatter = CurrencyFormatter()
    let usFormatter = CurrencyFormatter(locale: .US)
    let asset = Asset.mock()

    @Test
    func testValue() {
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "100,00 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000_123)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "100000,12 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satB, value: BigInt(1000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "4,00 sat/B"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(100_000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "0,0001 gwei"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "0,12 gwei"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789_012)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "123,46 gwei"
        )
    }

    @Test
    func testValueUS() {
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: usFormatter
            ).value == "100.00 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satB, value: BigInt(1000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: usFormatter
            ).value == "4.00 sat/B"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000_123)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: usFormatter
            ).value == "100,000.12 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(100_000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: usFormatter
            ).value == "0.0001 gwei"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: usFormatter
            ).value == "0.12 gwei"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789_012)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: usFormatter
            ).value == "123.46 gwei"
        )
    }
}
