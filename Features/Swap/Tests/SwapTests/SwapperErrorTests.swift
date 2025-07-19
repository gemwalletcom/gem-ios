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
    
    @Test
    func underlayingError() {
        let swapperError = SwapperError.TransactionError("Attempt to debit an account but found no record of a prior credit")
        let errorWrapper = ErrorWrapper(swapperError)
        
        #expect(errorWrapper.errorDescription == "Attempt to debit an account but found no record of a prior credit")
    }
}
