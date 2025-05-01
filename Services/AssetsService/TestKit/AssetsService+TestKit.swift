// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import Primitives
import Store
import StoreTestKit

public final class AssetsServiceMock: AssetsService, @unchecked Sendable {
    public var assetStore: AssetStore

    public init(assetStore: AssetStore = AssetStoreMock()) {
        self.assetStore = assetStore
    }

    public func addNewAsset(walletId: WalletId, asset: Asset) throws {}

    public var addedAssets: [AssetBasic] = []
    public func addAssets(assets: [AssetBasic]) throws {
        addedAssets.append(contentsOf: assets)
    }

    public var allAssets: [Asset] = []
    public func getAssets() throws -> [Asset] {
        allAssets
    }

    public var enabledAssets: [AssetId] = []
    public func getEnabledAssets() throws -> [AssetId] {
        enabledAssets
    }

    public var assetById: [String: Asset] = [:]
    public func getAsset(for assetId: AssetId) throws -> Asset {
        guard let asset = assetById[assetId.identifier] else {
            throw AnyError("Asset not found")
        }
        return asset
    }

    public func getOrFetchAsset(for assetId: AssetId) async throws -> Asset {
        try getAsset(for: assetId)
    }

    public var assetsByIds: [String: Asset] = [:]
    public func getAssets(for assetIds: [AssetId]) throws -> [Asset] {
        assetIds.compactMap { assetsByIds[$0.identifier] }
    }

    public func prefetchAssets(assetIds: [AssetId]) async throws -> [AssetId] {
        assetIds
    }

    public func addBalancesIfMissing(walletId: WalletId, assetIds: [AssetId]) throws {}
    public func addBalanceIfMissing(walletId: WalletId, assetId: AssetId) throws {}
    public func updateEnabled(walletId: WalletId, assetId: AssetId, enabled: Bool) throws {}
    public func updateAsset(assetId: AssetId) async throws {}

    public var fullAssetById: [String: AssetFull] = [:]
    public func getAsset(assetId: AssetId) async throws -> AssetFull {
        guard let asset = fullAssetById[assetId.identifier] else {
            throw AnyError("Full asset not found")
        }
        return asset
    }

    public var basicAssetsById: [String: AssetBasic] = [:]
    public func getAssets(assetIds: [AssetId]) async throws -> [AssetBasic] {
        assetIds.compactMap { basicAssetsById[$0.identifier] }
    }

    public var searchedAssets: [AssetBasic] = []
    public func searchAssets(query: String, chains: [Chain], tags: [AssetTag]) async throws -> [AssetBasic] {
        searchedAssets
    }
}
