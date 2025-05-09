// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Store
import StoreTestKit
import PrimitivesTestKit

struct AssetsRequestTests {

    @Test func testAddAssets() throws {
        let db = DB.mock()
        let store = AssetStore(db: db)
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock().fetch(db)
            
            #expect(assets.isEmpty)
        }
        
        try store.add(assets: [.mock()])
        
        try db.dbQueue.read { db in
            let assets = try AssetsRequest.mock(filters: [.priceAlerts]).fetch(db)
            
            #expect(assets.count == 1)
        }
    }
}

extension AssetsRequest {
    static func mock(
        walletId: String = "",
        searchBy: String = "",
        filters: [AssetsRequestFilter] = []
    ) -> AssetsRequest {
        AssetsRequest(walletId: walletId, searchBy: searchBy, filters: filters)
    }
}
