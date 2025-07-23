// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
@testable import Perpetuals

struct PerpetualViewModelTests {
    
    @Test
    func name() {
        #expect(PerpetualViewModel(perpetual: .mock(name: "BTC-PERP")).name == "BTC-PERP")
    }
    
    @Test
    func volumeText() {
        #expect(PerpetualViewModel(perpetual: .mock(volume24h: 1_500_000)).volumeText == "$1.5M")
    }
    
    @Test
    func openInterestText() {
        #expect(PerpetualViewModel(perpetual: .mock(openInterest: 5_250_000)).openInterestText == "$5.3M")
    }
    
    @Test
    func fundingRateText() {
        #expect(PerpetualViewModel(perpetual: .mock(funding: 0.0001)).fundingRateText.contains("%"))
    }
    
    @Test
    func priceText() {
        #expect(PerpetualViewModel(perpetual: .mock(price: 45000)).priceText == "$45K")
    }
}
