// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public actor GemAPIAssetsServiceMock: GemAPIAssetsService {
    private var assetResult: AssetFull?
    private var assetsResult: [AssetBasic]?
    private var searchAssetsResult: [AssetBasic]?

    public init(
        assetResult: AssetFull? = nil,
        assetsResult: [AssetBasic]? = nil,
        searchAssetsResult: [AssetBasic]? = nil
    ) {
        self.assetResult = assetResult
        self.assetsResult = assetsResult
        self.searchAssetsResult = searchAssetsResult
    }

    public func getAsset(assetId: AssetId) async throws -> AssetFull {
        assetResult!
    }

    public func getAssets(assetIds: [AssetId]) async throws -> [AssetBasic] {
        assetsResult!
    }

    public func getSearchAssets(query: String, chains: [Chain], tags: [AssetTag]) async throws -> [AssetBasic] {
        searchAssetsResult!
    }
}
