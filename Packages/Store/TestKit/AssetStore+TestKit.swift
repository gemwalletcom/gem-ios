// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

public final class AssetStoreMock: AssetStore, @unchecked Sendable {
    public var addedAssets: [AssetBasic] = []
    public var addedSearches: [(String, [AssetBasic])] = []
    public var returnedAssets: [Asset] = []
    public var returnedAssetsByIds: [String: Asset] = [:]
    public var buyableUpdated: [(ids: [String], value: Bool)] = []
    public var sellableUpdated: [(ids: [String], value: Bool)] = []
    public var swappableUpdated: [(ids: [String], value: Bool)] = []
    public var stakeableUpdated: [(ids: [String], value: Bool)] = []
    public var clearedTokensCount: Int = 0
    public var updatedLinks: [(AssetId, [AssetLink])] = []

    public init() {}

    public func add(assets: [AssetBasic]) throws {
        addedAssets.append(contentsOf: assets)
    }

    public func addAssetsSearch(query: String, assets: [AssetBasic]) throws {
        addedSearches.append((query, assets))
    }

    public func getAssets() throws -> [Asset] {
        returnedAssets
    }

    public func getAssets(for assetIds: [String]) throws -> [Asset] {
        assetIds.compactMap { returnedAssetsByIds[$0] }
    }

    public func setAssetIsBuyable(for assetIds: [String], value: Bool) throws -> Int {
        buyableUpdated.append((assetIds, value))
        return assetIds.count
    }

    public func setAssetIsSellable(for assetIds: [String], value: Bool) throws -> Int {
        sellableUpdated.append((assetIds, value))
        return assetIds.count
    }

    public func setAssetIsSwappable(for assetIds: [String], value: Bool) throws -> Int {
        swappableUpdated.append((assetIds, value))
        return assetIds.count
    }

    public func setAssetIsStakeable(for assetIds: [String], value: Bool) throws -> Int {
        stakeableUpdated.append((assetIds, value))
        return assetIds.count
    }

    public func clearTokens() throws -> Int {
        clearedTokensCount
    }

    public func updateLinks(assetId: AssetId, _ links: [AssetLink]) throws {
        updatedLinks.append((assetId, links))
    }
}
