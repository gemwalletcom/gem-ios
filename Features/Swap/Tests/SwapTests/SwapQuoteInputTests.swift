// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import BigInt
import Primitives
import PrimitivesTestKit
@testable import Swap

struct SwapQuoteInputTests {
    @Test
    func useMaxAmountWhenAmountEqualsAvailableBalance() throws {
        let availableBalance = BigInt("1000000000000000000")
        let fromAsset = AssetData.mock(
            asset: .mockEthereum(),
            balance: .mock(available: availableBalance)
        )
        let toAsset = AssetData.mock(asset: .mockEthereumUSDT())
        let formatter = SwapValueFormatter(valueFormatter: .full)

        let input = try SwapQuoteInput.create(
            fromAsset: fromAsset,
            toAsset: toAsset,
            fromValue: "1",
            formatter: formatter
        )

        #expect(input.value == availableBalance)
        #expect(input.useMaxAmount == true)
    }

    @Test
    func useMaxAmountWhenAmountIsLessThanAvailableBalance() throws {
        let availableBalance = BigInt("1000000000000000000")
        let fromAsset = AssetData.mock(
            asset: .mockEthereum(),
            balance: .mock(available: availableBalance)
        )
        let toAsset = AssetData.mock(asset: .mockEthereumUSDT())
        let formatter = SwapValueFormatter(valueFormatter: .full)

        let input = try SwapQuoteInput.create(
            fromAsset: fromAsset,
            toAsset: toAsset,
            fromValue: "0.5",
            formatter: formatter
        )

        #expect(input.value == BigInt("500000000000000000"))
        #expect(input.useMaxAmount == false)
    }

    @Test
    func useMaxAmountWithDifferentDecimals() throws {
        let availableBalance = BigInt("1000000")
        let usdtAsset = Asset.mockEthereumUSDT()
        let fromAsset = AssetData.mock(
            asset: usdtAsset,
            balance: .mock(available: availableBalance)
        )
        let toAsset = AssetData.mock(asset: .mockEthereum())
        let formatter = SwapValueFormatter(valueFormatter: .full)

        let input = try SwapQuoteInput.create(
            fromAsset: fromAsset,
            toAsset: toAsset,
            fromValue: "1",
            formatter: formatter
        )

        #expect(input.value == availableBalance)
        #expect(input.useMaxAmount == true)
    }
}
