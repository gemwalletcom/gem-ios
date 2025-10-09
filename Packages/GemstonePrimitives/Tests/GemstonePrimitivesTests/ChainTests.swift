// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import GemstonePrimitives

final class ChainTests {
    @Test
    func testAssetIsSwappable() {
        #expect(Chain.ethereum.isSwapSupported)
        #expect(Chain.smartChain.isSwapSupported)
    }
    
    @Test
    func transactionTimeoutSeconds() {
        #expect(Chain.ethereum.transactionTimeoutSeconds == 1440)
        #expect(Chain.solana.transactionTimeoutSeconds == 75)
    }
}
