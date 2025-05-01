// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

public final class AssetStoreMock: AssetStore, @unchecked Sendable {
    public init() {}

    public var addedAssets: [AssetBasic] = []
    public func add(assets: [AssetBasic]) throws {
        addedAssets.append(contentsOf: assets)
    }

    public func addAssetsSearch(query: String, assets: [AssetBasic]) throws {}

    public var returnedAssets: [Asset] = []
    public func getAssets() throws -> [Asset] {
        returnedAssets
    }

    public var returnedAssetsByIds: [String: Asset] = [:]
    public func getAssets(for assetIds: [String]) throws -> [Asset] {
        assetIds.compactMap { returnedAssetsByIds[$0] }
    }

    public func setAssetIsBuyable(for assetIds: [String], value: Bool) throws -> Int {
        assetIds.count
    }

    public func setAssetIsSellable(for assetIds: [String], value: Bool) throws -> Int {
        assetIds.count
    }

    public func setAssetIsSwappable(for assetIds: [String], value: Bool) throws -> Int {
        assetIds.count
    }

    public func setAssetIsStakeable(for assetIds: [String], value: Bool) throws -> Int {
        assetIds.count
    }

    public var clearedTokensCount: Int = 0
    public func clearTokens() throws -> Int {
        clearedTokensCount
    }

    public func updateLinks(assetId: AssetId, _ links: [AssetLink]) throws {}
}
