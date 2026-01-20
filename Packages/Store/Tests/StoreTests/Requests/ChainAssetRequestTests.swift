// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives

struct ChainAssetRequestTests {

    @Test
    func fetchNativeAsset() throws {
        let db = DB.mockAssets()
        let assetId = AssetId(chain: .ethereum)

        try db.dbQueue.read { db in
            let result = try ChainAssetRequest(walletId: .mock(), assetId: assetId).fetch(db)

            #expect(result.assetData.asset.id == assetId)
            #expect(result.feeAssetData.asset.id == assetId)
        }
    }

    @Test
    func fetchToken() throws {
        let db = DB.mockAssets()
        let token = Asset.mockEthereumUSDT()

        try db.dbQueue.read { db in
            let result = try ChainAssetRequest(walletId: .mock(), assetId: token.id).fetch(db)

            #expect(result.assetData.asset.id == token.id)
            #expect(result.feeAssetData.asset.id == token.chain.assetId)
        }
    }
}
