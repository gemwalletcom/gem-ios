// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import Blockchain

struct HyperCoreServiceTests {
    
    @Test
    func feeRate() {
        #expect(HyperCoreService.feeRate(50) == "0.05%")
        #expect(HyperCoreService.feeRate(100) == "0.1%")
    }
}