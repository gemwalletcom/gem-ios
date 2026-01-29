// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import enum Gemstone.SwapperError
import Primitives
import PrimitivesTestKit

@testable import Swap

struct SwapperErrorTests {

    @Test
    func isRetryAvailable() {
        #expect(SwapperError.NoQuoteAvailable.isRetryAvailable == true)
        #expect(SwapperError.ComputeQuoteError("error").isRetryAvailable == true)

        #expect(SwapperError.NotSupportedChain.isRetryAvailable == false)
        #expect(SwapperError.InputAmountError(minAmount: nil).isRetryAvailable == false)
    }

    @Test
    func inputAmountErrorMessage() {
        #expect(
            SwapperError.InputAmountError(minAmount: "120966091866986").message(asset: .mockBNB()) == 
            "Minimum trade amount is **0.0001209 BNB**. Please enter a higher amount."
        )
        #expect(
            SwapperError.InputAmountError(minAmount: "123456").message(asset: .mock(symbol: "USDT", decimals: 6)) ==
            "Minimum trade amount is **0.1234 USDT**. Please enter a higher amount."
        )
    }
}
