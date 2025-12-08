// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives

struct PerpetualRequestTests {

    @Test
    func fetch() throws {
        let db = DB.mockAssets()
        let store = PerpetualStore(db: db)
        let eth = AssetId(chain: .ethereum)
        let perpetual = Perpetual.mock(assetId: eth, price: 2500.0, maxLeverage: 100)

        try store.upsertPerpetuals([perpetual])
        try store.setPinned(for: [perpetual.id], value: true)

        try db.dbQueue.read { db in
            let result = try PerpetualRequest(assetId: eth).fetch(db)
            let notFound = try PerpetualRequest(assetId: AssetId(chain: .bitcoin)).fetch(db)

            #expect(result.perpetual.id == perpetual.id)
            #expect(result.perpetual.price == 2500.0)
            #expect(result.asset.id == eth)
            #expect(result.metadata.isPinned == true)
            #expect(notFound == .empty)
        }
    }
}
