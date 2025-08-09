// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Store
import StoreTestKit
import PrimitivesTestKit
import Primitives
import BigInt

struct BannersRequestTests {
    @Test func excludeActiveStaking() throws {
        let assetId = AssetId.mock()
        let db = DB.mockAssets(assets: [AssetBasic.mock(asset: Asset.mock(id: assetId))])
        let bannerStore = BannerStore(db: db)
        let balanceStore = BalanceStore(db: db)

        try bannerStore.addBanners([NewBanner.stake(assetId: assetId)])
        try balanceStore.updateBalances([UpdateBalance.mockStake(assetId: assetId)], for: .empty)

        try db.dbQueue.read { db in
            let banners = try BannersRequest(
                walletId: .empty,
                events: [.stake],
                filters: [.excludeActiveStaking]
            ).fetch(db)
            
            #expect(banners.isEmpty)
        }
    }
}
