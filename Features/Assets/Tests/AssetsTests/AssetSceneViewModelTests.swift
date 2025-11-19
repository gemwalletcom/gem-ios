// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import SwiftUI
import Primitives
import PrimitivesTestKit
import WalletsServiceTestKit
import AssetsServiceTestKit
import TransactionsServiceTestKit
import PriceServiceTestKit
import PriceAlertServiceTestKit
import BannerServiceTestKit

@testable import Assets

@MainActor
struct AssetSceneViewModelTests {
    
    @Test
    func showManageToken() {
        #expect(AssetSceneViewModel.mock(.mock(metadata: .mock(isBalanceEnabled: true))).showManageToken == false)
        #expect(AssetSceneViewModel.mock(.mock(metadata: .mock(isBalanceEnabled: false))).showManageToken == true)
    }
    
    @Test
    func showStatus() {
        #expect(AssetSceneViewModel.mock(.mock(metadata: .mock(rankScore: 42))).showStatus == false)
        #expect(AssetSceneViewModel.mock(.mock(metadata: .mock(rankScore: 10))).showStatus == true)
        #expect(AssetSceneViewModel.mock(.mock(metadata: .mock(rankScore: 3))).showStatus == false)
    }
}

// MARK: - Mock Extensions

extension AssetSceneViewModel {
    static func mock(
        _ assetData: AssetData = AssetData.mock(),
        banners: [Banner] = []
    ) -> AssetSceneViewModel {
        let viewModel = AssetSceneViewModel(
            walletsService: .mock(),
            assetsService: .mock(),
            transactionsService: .mock(),
            priceObserverService: .mock(),
            priceAlertService: .mock(),
            bannerService: .mock(),
            input: AssetSceneInput(
                wallet: .mock(),
                asset: assetData.asset
            ),
            isPresentingSelectedAssetInput: .constant(.none),
            navigationPath: .constant(NavigationPath())
        )
        viewModel.assetData = assetData
        viewModel.banners = banners
        return viewModel
    }
}
