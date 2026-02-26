// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Preferences

import WalletsServiceTestKit
import BalanceServiceTestKit
import BannerServiceTestKit
import WalletServiceTestKit
import PrimitivesTestKit
import PreferencesTestKit

@testable import WalletTab
@testable import Store

@MainActor
struct WalletSceneViewModelTests {
    @Test
    func isLoading() {
        let model = WalletSceneViewModel.mock()
        #expect(model.isLoadingAssets == false)

        model.shouldStartLoadingAssets()
        #expect(model.isLoadingAssets)

        model.fetch()
        #expect(!model.isLoadingAssets == false)
    }

    @Test
    func priorityBannerReturnsHighestPriority() {
        let model = WalletSceneViewModel.mock()
        model.bannersQuery.value = [
            .mock(event: .stake, state: .active),
            .mock(event: .enableNotifications, state: .cancelled),
            .mock(event: .accountActivation, state: .alwaysActive)
        ]

        #expect(model.walletBannersModel.allBanners.first?.state == .alwaysActive)
    }

    @Test
    func onChangeWalletUpdatesImageUrl() {
        let wallet = Wallet.mock(id: "1", imageUrl: nil)
        let model = WalletSceneViewModel.mock(wallet: wallet)

        #expect(model.wallet.imageUrl == nil)

        let updatedWallet = Wallet.mock(id: "1", imageUrl: "avatar.png")
        model.onChangeWallet(wallet, updatedWallet)

        #expect(model.wallet.imageUrl == "avatar.png")
    }

    @Test
    func onChangeWalletSwitchesToDifferentWallet() {
        let wallet = Wallet.mock(id: "1", name: "Wallet 1")
        let model = WalletSceneViewModel.mock(wallet: wallet)

        #expect(model.wallet.id == "1")

        let newWallet = Wallet.mock(id: "2", name: "Wallet 2")
        model.onChangeWallet(wallet, newWallet)

        #expect(model.wallet.id == "2")
    }
}

extension WalletSceneViewModel {
    static func mock(wallet: Wallet = .mock()) -> WalletSceneViewModel {
        WalletSceneViewModel(
            assetDiscoveryService: .mock(),
            balanceUpdater: .mock(),
            balanceService: .mock(),
            bannerService: .mock(),
            walletService: .mock(),
            observablePreferences: .mock(),
            wallet: wallet,
            isPresentingSelectedAssetInput: .constant(.none)
        )
    }
}
