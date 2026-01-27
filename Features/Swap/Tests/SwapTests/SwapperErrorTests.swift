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
    func messageCeilsPrecisionTo8Decimals() {
        let asset = Asset.mockBNB()
        let error = SwapperError.InputAmountError(minAmount: "120966091866986")

        #expect(error.message(asset: asset) == "Minimum trade amount is **0.00012097 BNB**. Please enter a higher amount.")
    }

    @Test
    func messageNoCeilingWhenDecimalsLessThan8() {
        let asset = Asset.mock(symbol: "USDT", decimals: 6)
        let error = SwapperError.InputAmountError(minAmount: "123456")

        #expect(error.message(asset: asset) == "Minimum trade amount is **0.123456 USDT**. Please enter a higher amount.")
    }
}
