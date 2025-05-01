// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public actor GemAPIAssetsListServiceMock: GemAPIAssetsListService {
    public var assetsByDeviceIdResult: [AssetId] = []
    public var buyableFiatAssetsResult: FiatAssets?
    public var sellableFiatAssetsResult: FiatAssets?
    public var swapAssetsResult: FiatAssets?

    public private(set) var receivedDeviceId: String?
    public private(set) var receivedWalletIndex: Int?
    public private(set) var receivedTimestamp: Int?

    public init() {}

    public func getAssetsByDeviceId(deviceId: String, walletIndex: Int, fromTimestamp: Int) async throws -> [AssetId] {
        receivedDeviceId = deviceId
        receivedWalletIndex = walletIndex
        receivedTimestamp = fromTimestamp
        return assetsByDeviceIdResult
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
