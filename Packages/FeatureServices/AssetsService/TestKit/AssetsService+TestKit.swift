// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import Primitives
import Store
import StoreTestKit
import ChainService
import ChainServiceTestKit
import GemAPITestKit
import GemAPI

extension AssetsService {
    public static func mock(
        assetStore: AssetStore = .mock(),
        balanceStore: BalanceStore = .mock(),
        chainServiceFactory: any ChainServiceFactorable = ChainServiceFactoryMock(),
        assetsProvider: any GemAPIAssetsService = GemAPIAssetsServiceMock()
    ) -> AssetsService {
        AssetsService(
            assetStore: assetStore,
            balanceStore: balanceStore,
            chainServiceFactory: chainServiceFactory,
            assetsProvider: assetsProvider
        )
    }
}
