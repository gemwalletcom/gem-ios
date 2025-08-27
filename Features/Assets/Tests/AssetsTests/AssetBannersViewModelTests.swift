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
    
    @Test
    func suspiciousAssetBanner() {
        let suspicious = AssetBannersViewModel(assetData: .mock(metadata: .mock(rankScore: 5)), banners: [])
        #expect(suspicious.allBanners.count == 1)
        #expect(suspicious.allBanners.first?.event == .suspiciousAsset)

        #expect(AssetBannersViewModel(assetData: .mock(metadata: .mock(rankScore: 50)), banners: []).allBanners.isEmpty)
    }
    
    @Test
    func accountActivationBanner() {
        #expect(AssetBannersViewModel(
            assetData: .mock(asset: .mockXRP(), balance: .zero, metadata: .mock(rankScore: 16)),
            banners: [
                .mock(event: .accountActivation)
            ]
        ).allBanners.first?.event == .accountActivation)
        
        #expect(AssetBannersViewModel(
            assetData: .mock(balance: Balance(available: BigInt(1)), metadata: .mock(rankScore: 16)),
            banners: [
                .mock(event: .accountActivation)
            ]
        ).allBanners.isEmpty)
	}

	@Test
    func nonClosableBannersShowFirst() {
        let model = AssetBannersViewModel(
            assetData: .mock(metadata: .mock(rankScore: 5)),
            banners: [.mock(event: .stake, state: .active), .mock(event: .accountActivation, state: .alwaysActive)]
        )

        #expect(model.allBanners.count == 3)
        #expect(model.allBanners[0].state == .alwaysActive)
        #expect(model.allBanners[1].state == .alwaysActive)
        #expect(model.allBanners[2].state == .active)
    }
}
