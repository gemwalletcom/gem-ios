// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesTestKit

@testable import Primitives

final class PriceAlertTests {
    
    @Test func testId() {
        #expect(PriceAlert.mock().id == "bitcoin")
        #expect(PriceAlert.mock(price: 1, priceDirection: .up).id == "bitcoin_USD_1_up")
        #expect(PriceAlert.mock(pricePercentChange: 1).id == "bitcoin_USD_1")
        #expect(PriceAlert.mock(pricePercentChange: 0.23).id == "bitcoin_USD_0.23")
        #expect(PriceAlert.mock(pricePercentChange: 1.12344).id == "bitcoin_USD_1.12344")
        #expect(PriceAlert.mock(pricePercentChange: 10_000.10).id == "bitcoin_USD_10000.1")
    }
    
    @Test func testAutoAlertType() {
        #expect(PriceAlert.mock(assetId: .mock()).type == .auto)
    }

    @Test func testPriceAlertType() {
        let priceAlert = PriceAlert.mock(
            assetId: .mock(),
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
