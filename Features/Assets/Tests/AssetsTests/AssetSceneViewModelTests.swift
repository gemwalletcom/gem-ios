// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import SwiftUI
import Primitives
import PrimitivesTestKit
import WalletsServiceTestKit
import AssetsServiceTestKit
import BalanceServiceTestKit
import TransactionsServiceTestKit
import PriceServiceTestKit
import PriceAlertServiceTestKit
import BannerServiceTestKit

@testable import Assets
@testable import Store

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
    static func mock(_ assetData: AssetData = AssetData.mock()) -> AssetSceneViewModel {
        let model = AssetSceneViewModel(
            assetsEnabler: .mock(),
            assetSyncService: .mock(),
            balanceService: .mock(),
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
        model.assetQuery.value = ChainAssetData(
            assetData: assetData,
            feeAssetData: AssetData.with(asset: assetData.asset.chain.asset)
        )
        return model
    }
}
