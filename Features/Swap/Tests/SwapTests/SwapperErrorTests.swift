// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import enum Gemstone.SwapperError

@testable import Swap

struct SwapperErrorTests {
    
    @Test
    func isRetryAvailable() {
        #expect(SwapperError.NoQuoteAvailable.isRetryAvailable == true)
        #expect(SwapperError.NetworkError("error").isRetryAvailable == true)
        
        #expect(SwapperError.NotSupportedChain.isRetryAvailable == false)
        #expect(SwapperError.InvalidAmount("").isRetryAvailable == false)
    }
}
