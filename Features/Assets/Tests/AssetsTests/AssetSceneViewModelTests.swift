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

    @Test
    func swapAssetTypeNative() {
        let asset = Asset.mock(type: .native)
        let model = AssetSceneViewModel.mock(.mock(asset: asset, balance: .zero))

        #expect(model.swapAssetType == .swap(asset, nil))
    }

    @Test
    func swapAssetTypeTokenWithZeroBalance() {
        let asset = Asset.mockEthereumUSDT()
        let model = AssetSceneViewModel.mock(.mock(asset: asset, balance: .zero))

        #expect(model.swapAssetType == .swap(asset.chain.asset, asset))
    }

    @Test
    func swapAssetTypeTokenWithBalance() {
        let asset = Asset.mockEthereumUSDT()
        let model = AssetSceneViewModel.mock(.mock(asset: asset, balance: .mock()))

        #expect(model.swapAssetType == .swap(asset, nil))
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
            isPresentingSelectedAssetInput: .constant(.none)
        )
        viewModel.chainAssetData = ChainAssetData(
            assetData: assetData,
            nativeAssetData: AssetData.with(asset: assetData.asset.chain.asset)
        )
        viewModel.banners = banners
        return viewModel
    }
}
