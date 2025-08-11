// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import BigInt

@testable import Assets

@MainActor
struct AssetBannersViewModelTests {
    
    @Test
    func stakingBannerFiltering() {
        let withStake = AssetBannersViewModel(assetData: .mock(balance: Balance(staked: BigInt(100))), banners: [.mock(event: .stake)])
        #expect(withStake.allBanners.isEmpty)
        
        let noStake = AssetBannersViewModel(assetData: .mock(balance: Balance(staked: .zero)), banners: [.mock(event: .stake)])
        #expect(noStake.allBanners.count == 1)
    }
    
    @Test
    func activateAssetBanner() {
        let inactive = AssetBannersViewModel(assetData: .mock(metadata: .mock(isActive: false)), banners: [])
        #expect(inactive.allBanners.count == 1)
        #expect(inactive.allBanners.first?.event == .activateAsset)

        let active = AssetBannersViewModel(assetData: .mock(metadata: .mock(isActive: true)), banners: [])
        #expect(active.allBanners.isEmpty)
    }
}
