// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import BigInt
import Primitives
import PrimitivesTestKit
import Formatters

@testable import PrimitivesComponents

struct FeeUnitViewModelTests {
    let formatter = CurrencyFormatter(currencyCode: .empty)
    let usFormatter = CurrencyFormatter(locale: .US, currencyCode: .empty)
    let asset = Asset.mock()

    @Test
    func testValue() {
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "100,000 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000_123)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "100,000,123 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(1000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "1,000 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(100_000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "0.0001 gwei"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "0.1235 gwei"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .gwei, value: BigInt(123_456_789_012)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: formatter
            ).value == "123.46 gwei"
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
            ).value == "100,000 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(1000)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: usFormatter
            ).value == "1,000 sat/vB"
        )
        #expect(
            FeeUnitViewModel(
                unit: FeeUnit(type: .satVb, value: BigInt(100_000_123)),
                decimals: Int(asset.decimals),
                symbol: asset.symbol,
                formatter: usFormatter
            ).value == "100,000,123 sat/vB"
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
            ).value == "0.1235 gwei"
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
