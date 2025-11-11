// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Preferences

import WalletsServiceTestKit
import BannerServiceTestKit
import WalletServiceTestKit
import PrimitivesTestKit
import PreferencesTestKit

@testable import WalletTab

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
        model.banners = [
            .mock(event: .stake, state: .active),
            .mock(event: .enableNotifications, state: .cancelled),
            .mock(event: .accountActivation, state: .alwaysActive)
        ]

        #expect(model.walletBannersModel.allBanners.first?.state == .alwaysActive)
    }

}

extension WalletSceneViewModel {
    static func mock() -> WalletSceneViewModel {
        WalletSceneViewModel(
            walletsService: .mock(),
            bannerService: .mock(),
            walletService: .mock(),
            observablePreferences: .mock(),
            wallet: .mock(),
            isPresentingSelectedAssetInput: .constant(.none),
            isPresentingConfirmTransfer: .constant(.none)
        )
    }
}
