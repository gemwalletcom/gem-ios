// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives

struct WalletSearchRequestTests {

    @Test
    func searchAssets() throws {
        let db = DB.mockAssets()
        let searchStore = SearchStore(db: db)

        try db.dbQueue.read { db in
            let btc = try WalletSearchRequest(walletId: .mock(), searchBy: "btc").fetch(db)
            let tokenId = try WalletSearchRequest(walletId: .mock(), searchBy: "0xdAC17F958D2ee523a2206206994597C13D831ec7").fetch(db)

            #expect(btc.assets.first?.asset.symbol == "BTC")
            #expect(tokenId.assets.first?.asset.symbol == "USDT")
        }

        let query = "priority test"
        let expectedOrder = [AssetBasic].mock().reversed().map { $0.asset.id.identifier }
        try searchStore.add(type: .asset, query: query, ids: expectedOrder)

        try db.dbQueue.read { db in
            let result = try WalletSearchRequest(walletId: .mock(), searchBy: query, limit: 10).fetch(db)
            #expect(result.assets.map { $0.asset.id.identifier } == expectedOrder)
        }
    }

    @Test
    func searchPerpetuals() throws {
        let db = DB.mockAssets()
        let store = PerpetualStore(db: db)
        let searchStore = SearchStore(db: db)

        let ethPerpetual = Perpetual.mock(id: "hypercore_ETH-USD", name: "ETH-USD", assetId: AssetId(chain: .ethereum))
        let btcPerpetual = Perpetual.mock(id: "hypercore_BTC-USD", name: "BTC-USD", assetId: AssetId(chain: .bitcoin))
        try store.upsertPerpetuals([ethPerpetual, btcPerpetual])

        try db.dbQueue.read { db in
            let result = try WalletSearchRequest(walletId: .mock(), searchBy: "ETH").fetch(db)
            #expect(result.perpetuals.first?.perpetual.name == "ETH-USD")
        }

        let query = "perp priority"
        try searchStore.add(type: .perpetual, query: query, ids: [btcPerpetual.id, ethPerpetual.id])

        try db.dbQueue.read { db in
            let result = try WalletSearchRequest(walletId: .mock(), searchBy: query).fetch(db)
            #expect(result.perpetuals.first?.perpetual.id == btcPerpetual.id)

            let withTag = try WalletSearchRequest(walletId: .mock(), searchBy: "ETH", tag: "staking").fetch(db)
            #expect(withTag.perpetuals.isEmpty)
        }
    }
}
