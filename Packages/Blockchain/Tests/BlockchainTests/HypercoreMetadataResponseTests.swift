// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import Blockchain

struct HypercoreMetadataResponseTests {
    
    @Test
    func fundingRateConversion() {
        let metadata = HypercoreAssetMetadata(
            funding: "0.0000794237",
            openInterest: "1000000",
            prevDayPx: "100",
            dayNtlVlm: "5000000",
            premium: nil,
            oraclePx: "100",
            markPx: "100",
            midPx: nil,
            impactPxs: nil,
            dayBaseVlm: "0"
        )
        
        let perpetual = metadata.mapToPerpetual(symbol: "BTC", maxLeverage: 100)!
        #expect(abs(perpetual.funding - 69.5431812) < 0.0001)
    }
    
    @Test
    func negativeFundingRate() {
        let metadata = HypercoreAssetMetadata(
            funding: "-0.0000125",
            openInterest: "0",
            prevDayPx: "100",
            dayNtlVlm: "0",
            premium: nil,
            oraclePx: "100",
            markPx: "100",
            midPx: nil,
            impactPxs: nil,
            dayBaseVlm: "0"
        )
        
        let perpetual = metadata.mapToPerpetual(symbol: "ETH", maxLeverage: 50)!
        #expect(abs(perpetual.funding - (-10.95)) < 0.0001)
    }
    
    @Test
    func priceUsesMarkPx() {
        let metadata = HypercoreAssetMetadata(
            funding: "0",
            openInterest: "0",
            prevDayPx: "100",
            dayNtlVlm: "0",
            premium: nil,
            oraclePx: "110",
            markPx: "110",
            midPx: nil,
            impactPxs: nil,
            dayBaseVlm: "0"
        )
        
        let perpetual = metadata.mapToPerpetual(symbol: "SOL", maxLeverage: 20)!
        #expect(perpetual.price == 110)
        #expect(perpetual.pricePercentChange24h == 10.0)
    }
}