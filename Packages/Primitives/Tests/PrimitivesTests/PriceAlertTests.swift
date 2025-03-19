// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesTestKit

@testable import Primitives

final class PriceAlertTests {
    
    @Test func testId() {
        #expect(PriceAlert.mock().id == "ethereum")
        #expect(PriceAlert.mock(price: 1, priceDirection: .up).id == "ethereum_USD_1.0_up")
        #expect(PriceAlert.mock(pricePercentChange: 1).id == "ethereum_USD_1.0")
    }
    
    @Test func testAutoAlertType() {
        #expect(PriceAlert.mock(assetId: "BTC").type == .auto)
    }

    @Test func testPriceAlertType() {
        let priceAlert = PriceAlert.mock(
            assetId: "ETH",
            price: 3000,
            priceDirection: .up
        )
        #expect(priceAlert.type == .price)
    }

    @Test func testPercentChangeAlertType() {
        let percentChangeAlert = PriceAlert.mock(
            pricePercentChange: 5.0,
            priceDirection: .down
        )
        #expect(percentChangeAlert.type == .pricePercentChange)
    }

    @Test func testPriceAndPercentAlertType() {
        let priceAndPercentAlert = PriceAlert.mock(
            price: 1.2,
            pricePercentChange: 3.5
        )
        #expect(priceAndPercentAlert.type == .auto)
    }
}
