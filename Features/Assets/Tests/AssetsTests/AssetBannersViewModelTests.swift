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
        let withStake = AssetSceneBannersViewModel(assetData: .mock(balance: Balance(staked: BigInt(100))), banners: [.mock(event: .stake)], wallet: .mock())
        #expect(withStake.allBanners.isEmpty)

        let noStake = AssetSceneBannersViewModel(assetData: .mock(balance: Balance(staked: .zero)), banners: [.mock(event: .stake)], wallet: .mock())
        #expect(noStake.allBanners.count == 1)
    }

    @Test
    func stakeBannerHiddenForViewOnlyWallet() {
        let viewOnlyWallet = AssetSceneBannersViewModel(
            assetData: .mock(balance: Balance(staked: .zero)),
            banners: [.mock(event: .stake)],
            wallet: .mock(type: .view)
        )
        #expect(viewOnlyWallet.allBanners.isEmpty)

        let regularWallet = AssetSceneBannersViewModel(
            assetData: .mock(balance: Balance(staked: .zero)),
            banners: [.mock(event: .stake)],
            wallet: .mock(type: .multicoin)
        )
        #expect(regularWallet.allBanners.count == 1)
    }

    @Test
    func activateAssetBanner() {
        let inactive = AssetSceneBannersViewModel(assetData: .mock(metadata: .mock(isActive: false)), banners: [], wallet: .mock())
        #expect(inactive.allBanners.count == 1)
        #expect(inactive.allBanners.first?.event == .activateAsset)

        let active = AssetSceneBannersViewModel(assetData: .mock(metadata: .mock(isActive: true)), banners: [], wallet: .mock())
        #expect(active.allBanners.isEmpty)
    }

    @Test
    func suspiciousAssetBanner() {
        let suspicious = AssetSceneBannersViewModel(assetData: .mock(metadata: .mock(rankScore: 5)), banners: [], wallet: .mock())
        #expect(suspicious.allBanners.count == 1)
        #expect(suspicious.allBanners.first?.event == .suspiciousAsset)

        #expect(AssetSceneBannersViewModel(assetData: .mock(metadata: .mock(rankScore: 50)), banners: [], wallet: .mock()).allBanners.isEmpty)
    }

    @Test
    func accountActivationBanner() {
        #expect(AssetSceneBannersViewModel(
            assetData: .mock(asset: .mockXRP(), balance: .zero, metadata: .mock(rankScore: 16)),
            banners: [.mock(event: .accountActivation)],
            wallet: .mock()
        ).allBanners.first?.event == .accountActivation)

        #expect(AssetSceneBannersViewModel(
            assetData: .mock(balance: Balance(available: BigInt(1)), metadata: .mock(rankScore: 16)),
            banners: [.mock(event: .accountActivation)],
            wallet: .mock()
        ).allBanners.isEmpty)
    }

    @Test
    func nonClosableBannersShowFirst() {
        let model = AssetSceneBannersViewModel(
            assetData: .mock(metadata: .mock(rankScore: 5)),
            banners: [.mock(event: .stake, state: .active), .mock(event: .accountActivation, state: .alwaysActive)],
            wallet: .mock()
        )

        #expect(model.allBanners.count == 3)
        #expect(model.allBanners[0].state == .alwaysActive)
        #expect(model.allBanners[1].state == .alwaysActive)
        #expect(model.allBanners[2].state == .active)
    }

    @Test
    func priorityBannerReturnsHighestPriority() {
        let model = AssetSceneBannersViewModel(
            assetData: .mock(),
            banners: [
                .mock(event: .stake, state: .active),
                .mock(event: .enableNotifications, state: .cancelled),
                .mock(event: .accountActivation, state: .alwaysActive)
            ],
            wallet: .mock()
        )

        #expect(model.allBanners.first?.state == .alwaysActive)
    }
}
