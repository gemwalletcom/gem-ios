// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public actor GemAPIAssetsListServiceMock: GemAPIAssetsListService {
    private var assetsByDeviceIdResult: [AssetId]?
    private var buyableFiatAssetsResult: FiatAssets?
    private var sellableFiatAssetsResult: FiatAssets?
    private var swapAssetsResult: FiatAssets?

    public init(
        assetsByDeviceIdResult: [AssetId]? = nil,
        buyableFiatAssetsResult: FiatAssets? = nil,
        sellableFiatAssetsResult: FiatAssets? = nil,
        swapAssetsResult: FiatAssets? = nil
    ) {
        self.assetsByDeviceIdResult = assetsByDeviceIdResult
        self.buyableFiatAssetsResult = buyableFiatAssetsResult
        self.sellableFiatAssetsResult = sellableFiatAssetsResult
        self.swapAssetsResult = swapAssetsResult
    }

    public func getDeviceAssets(walletId: String, fromTimestamp: Int) async throws -> [AssetId] {
        assetsByDeviceIdResult!
    }

    public func getBuyableFiatAssets() async throws -> FiatAssets {
        buyableFiatAssetsResult!
    }

    public func getSellableFiatAssets() async throws -> FiatAssets {
        sellableFiatAssetsResult!
    }

    public func getSwapAssets() async throws -> FiatAssets {
        swapAssetsResult!
    }
}
