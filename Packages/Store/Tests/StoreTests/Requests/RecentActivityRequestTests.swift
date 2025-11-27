// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives

struct RecentActivityRequestTests {

    @Test
    func fetchRecentAssets() throws {
        let db = DB.mockAssets()
        let store = RecentActivityStore(db: db)
        let btc = AssetId(chain: .bitcoin)
        let bnb = AssetId(chain: .smartChain)
        let now = Date()

        try store.add(assetId: btc, walletId: WalletId(id: ""), type: .search, timestamp: now.addingTimeInterval(-2))
        try store.add(assetId: bnb, walletId: WalletId(id: ""), type: .search, timestamp: now.addingTimeInterval(-1))
        try store.add(assetId: btc, walletId: WalletId(id: ""), type: .transfer, timestamp: now)

        try db.dbQueue.read { db in
            let result = try RecentActivityRequest(walletId: "", limit: 10).fetch(db)

            #expect(result.count == 2)
            #expect(result.first?.asset.id == btc)
            #expect(result.last?.asset.id == bnb)
        }
    }
}
