// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Primitives

final class PriceAlertTests {
    @Test
    func testAutoAlertType() {
        let autoAlert = PriceAlert(
            assetId: "BTC",
            price: nil,
            pricePercentChange: nil,
            priceDirection: nil,
            lastNotifiedAt: nil
        )
        #expect(autoAlert.type == .auto)
    }

    @Test
    func testPriceAlertType() {
        let priceAlert = PriceAlert(
            assetId: "ETH",
            price: 3000,
            pricePercentChange: nil,
            priceDirection: .up,
            lastNotifiedAt: nil
        )
        #expect(priceAlert.type == .price)
    }

    @Test
    func testPercentChangeAlertType() {
        let percentChangeAlert = PriceAlert(
            assetId: "XRP",
            price: nil,
            pricePercentChange: 5.0,
            priceDirection: .down,
            lastNotifiedAt: nil
        )
        #expect(percentChangeAlert.type == .pricePercentChange)
    }

    @Test
    func testPriceAndPercentAlertType() {
        let priceAndPercentAlert = PriceAlert(
            assetId: "ADA",
            price: 1.2,
            pricePercentChange: 3.5,
            priceDirection: nil,
            lastNotifiedAt: nil
        )
        #expect(priceAndPercentAlert.type == .auto)
    }
}
