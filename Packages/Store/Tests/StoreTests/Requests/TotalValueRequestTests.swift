// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives

struct TotalValueRequestTests {

    @Test
    func walletBalanceWithPrice() throws {
        let db = DB.mockAssets()
        let priceStore = PriceStore(db: db)

        let ethId = AssetId(chain: .ethereum)
        try priceStore.updatePrice(
            price: AssetPrice(assetId: ethId, price: 3000, priceChangePercentage24h: 10, updatedAt: .now),
            currency: Currency.usd.rawValue
        )

        try db.dbQueue.read { db in
            let result = try TotalValueRequest(walletId: .mock(), balanceType: .wallet).fetch(db)

            #expect(result.value > 0)
            #expect(result.pnlAmount != 0)
            #expect(result.pnlPercentage != 0)
        }
    }

    @Test
    func walletBalanceWithoutPrice() throws {
        let db = DB.mockAssets()

        try db.dbQueue.read { db in
            let result = try TotalValueRequest(walletId: .mock(), balanceType: .wallet).fetch(db)

            #expect(result.value == 0)
            #expect(result.pnlAmount == 0)
            #expect(result.pnlPercentage == 0)
        }
    }

    @Test
    func walletBalanceZeroChange() throws {
        let db = DB.mockAssets()
        let priceStore = PriceStore(db: db)

        let ethId = AssetId(chain: .ethereum)
        try priceStore.updatePrice(
            price: AssetPrice(assetId: ethId, price: 3000, priceChangePercentage24h: 0, updatedAt: .now),
            currency: Currency.usd.rawValue
        )

        try db.dbQueue.read { db in
            let result = try TotalValueRequest(walletId: .mock(), balanceType: .wallet).fetch(db)

            #expect(result.value > 0)
            #expect(result.pnlAmount == 0)
            #expect(result.pnlPercentage == 0)
        }
    }
}
