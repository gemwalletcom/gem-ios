// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Store
import Primitives
import PrimitivesTestKit
import StoreTestKit

struct PriceStoreTests {

    @Test
    func firstInsertAppliesCurrencyRate() throws {
        let db = DB.mockWithChains([.ethereum])
        let priceStore = PriceStore(db: db)
        let fiatRateStore = FiatRateStore(db: db)

        let assetId = Chain.ethereum.assetId
        let rate = 90.0
        let priceUsd = 2500.0
        let currency = Currency.rub.rawValue

        try fiatRateStore.add([FiatRate(symbol: currency, rate: rate)])
        try priceStore.updatePrices(prices: [.mock(assetId: assetId, price: priceUsd)], currency: currency)

        let result = try priceStore.getPrices(for: [assetId.identifier])

        #expect(result.first?.price == priceUsd * rate)
    }
}
