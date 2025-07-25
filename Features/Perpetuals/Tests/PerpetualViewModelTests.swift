// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PerpetualsTestKit
@testable import Perpetuals

private func mock(
    id: String = "test-perpetual",
    name: String = "BTC-USDT", 
    provider: PerpetualProvider = .hypercore,
    assetId: AssetId = AssetId(chain: .bitcoin, tokenId: nil),
    price: Double = 50000,
    pricePercentChange24h: Double = 5.0,
    leverage: [UInt8] = [1, 5, 10, 25, 50],
    openInterest: Double = 1000000,
    volume24h: Double = 5000000,
    funding: Double = 0.01
) -> Perpetual {
    Perpetual.mock(
        id: id,
        name: name,
        provider: provider,
        assetId: assetId,
        price: price,
        pricePercentChange24h: pricePercentChange24h,
        leverage: leverage,
        openInterest: openInterest,
        volume24h: volume24h,
        funding: funding
    )
}

struct PerpetualViewModelTests {
    
    @Test
    func name() {
        #expect(PerpetualViewModel(perpetual: mock(name: "BTC-PERP")).name == "BTC-PERP")
    }
    
    @Test
    func volumeText() {
        #expect(PerpetualViewModel(perpetual: mock(volume24h: 1_500_000)).volumeText == "$1.5M")
    }
    
    @Test
    func openInterestText() {
        #expect(PerpetualViewModel(perpetual: mock(openInterest: 5_250_000)).openInterestText == "$5.25M")
    }
    
    @Test
    func fundingRateText() {
        #expect(PerpetualViewModel(perpetual: mock(funding: 0.0001)).fundingRateText.contains("%"))
    }
    
    @Test
    func priceText() {
        #expect(PerpetualViewModel(perpetual: mock(price: 45000)).priceText == "$45,000.00")
    }
}
