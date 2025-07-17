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
}

extension WalletSceneViewModel {
    static func mock() -> WalletSceneViewModel {
        WalletSceneViewModel(
            walletsService: .mock(),
            bannerService: .mock(),
            walletService: .mock(),
            observablePreferences: .mock(),
            wallet: .mock(),
            isPresentingSelectedAssetInput: .constant(.none)
        )
    }
}
