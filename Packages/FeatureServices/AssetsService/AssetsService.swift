import Foundation
import Store
import Primitives
import GemAPI
import ChainService
import Blockchain

public final class AssetsService: Sendable {
    public let assetStore: AssetStore
    let balanceStore: BalanceStore
    let assetsProvider: any GemAPIAssetsService
    let chainServiceFactory: ChainServiceFactory

    public init(
        assetStore: AssetStore,
        balanceStore: BalanceStore,
        chainServiceFactory: ChainServiceFactory,
        assetsProvider: any GemAPIAssetsService = GemAPIService.shared
    ) {
        self.assetStore = assetStore
        self.balanceStore = balanceStore
        self.chainServiceFactory = chainServiceFactory
        self.assetsProvider = assetsProvider
    }

    // Used to add new custom assets
    public func addNewAsset(walletId: WalletId, asset: Asset) throws {
        try addAssets(assets: [
            AssetBasic(
                asset: asset,
                properties: AssetProperties.defaultValue(assetId: asset.id),
                score: AssetScore.defaultValue(assetId: asset.id)
            )
        ])
        try addBalanceIfMissing(walletId: walletId, assetId: asset.id)
        try updateEnabled(walletId: walletId, assetIds: [asset.id], enabled: true)
    }

    public func addAssets(assets: [AssetBasic]) throws {
        return try assetStore.add(assets: assets)
    }

    public func getAssets() throws -> [Asset] {
        return try assetStore.getAssets()
    }

    public func getEnabledAssets() throws -> [AssetId] {
        return try balanceStore.getEnabledAssetIds()
    }

    public func getAsset(for assetId: AssetId) throws -> Asset {
        if let asset = try assetStore.getAssets(for: [assetId.identifier]).first {
            return asset
        }
        throw AnyError("asset not found")
    }

    public func getOrFetchAsset(for assetId: AssetId) async throws -> Asset {
        if let asset = try assetStore.getAssets(for: [assetId.identifier]).first {
            return asset
        }
        try await prefetchAssets(assetIds: [assetId])
        return try getAsset(for: assetId)
    }
    
    public func getAssets(for assetIds: [AssetId]) throws -> [Asset] {
        return try assetStore.getAssets(for: assetIds.ids)
    }

    public func addBalancesIfMissing(walletId: WalletId, assetIds: [AssetId]) throws {
        for assetId in assetIds {
            try addBalanceIfMissing(walletId: walletId, assetId: assetId)
        }
    }

    @discardableResult
    public func prefetchAssets(assetIds: [AssetId]) async throws -> [AssetId] {
        let assets = try getAssets(for: assetIds).map { $0.id }.asSet()
        let missingAssetIds = assetIds.asSet().subtracting(assets)

        if missingAssetIds.isEmpty {
            return []
        }
        
        // add missing assets to local storage
        let newAssets = try await getAssets(assetIds: missingAssetIds.asArray())
        try addAssets(assets: newAssets)

        return newAssets.map { $0.asset.id }
    }

    public func addBalanceIfMissing(walletId: WalletId, assetId: AssetId) throws {
        let exist = try balanceStore.isBalanceExist(walletId: walletId.id, assetId: assetId.identifier)
        if !exist {
            let balance = AddBalance(assetId: assetId, isEnabled: false)
            try balanceStore.addBalance([balance], for: walletId.id)
        }
    }

    public func updateEnabled(walletId: WalletId, assetIds: [AssetId], enabled: Bool) throws {
        try balanceStore.setIsEnabled(walletId: walletId.id, assetIds: assetIds.map { $0.identifier }, value: enabled)
    }

    public func updateAsset(assetId: AssetId) async throws {
        let asset = try await getAsset(assetId: assetId)
        try assetStore.add(assets: [asset.basic])
        try assetStore.updateLinks(assetId: assetId, asset.links)
    }
    
    public func addAssets(assetIds: [AssetId]) async throws {
        let assets = try await getAssets(assetIds: assetIds)
        try assetStore.add(assets: assets)
    }

    public func getAsset(assetId: AssetId) async throws -> AssetFull {
        try await assetsProvider
            .getAsset(assetId: assetId)
    }

    public func getAssets(assetIds: [AssetId]) async throws -> [AssetBasic] {
        try await assetsProvider
            .getAssets(assetIds: assetIds)
    }

    // search

    public func searchAssets(query: String, chains: [Chain], tags: [AssetTag]) async throws -> [AssetBasic] {
        let assets = try await withThrowingTaskGroup(of: [AssetBasic]?.self) { group in
            var assets = [AssetBasic]()

            group.addTask { [weak self] in
                guard let self = self else { return [] }
                return try await self.searchAPIAssets(query: query, chains: chains, tags: tags)
            }
            group.addTask { [weak self] in
                guard let self = self else { return [] }
                return try await self.searchNetworkAsset(tokenId: query, chains: chains.isEmpty ? Chain.allCases : chains)
            }

            for try await result in group {
                if let result = result, result.count > 0 {
                    assets.append(contentsOf: result)
                }
            }
            return assets
        }
        return assets
    }

    func searchAPIAssets(query: String, chains: [Chain], tags: [AssetTag]) async throws -> [AssetBasic] {
        try await assetsProvider.getSearchAssets(query: query, chains: chains, tags: tags)
    }

    func searchNetworkAsset(tokenId: String, chains: [Chain]) async throws -> [AssetBasic] {
        try await withThrowingTaskGroup(of: AssetBasic?.self) { group in
            chains.forEach { chain in
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    let service = self.chainServiceFactory.service(for: chain)
                    guard try await service.getIsTokenAddress(tokenId: tokenId),
                          let asset = try? await service.getTokenData(tokenId: tokenId),
                          !asset.symbol.isEmpty, // validate token metadata, move to core ?
                          !asset.name.isEmpty
                    else { return nil }

                    return AssetBasic(
                        asset: asset,
                        properties: .defaultValue(assetId: asset.id),
                        score: .defaultValue(assetId: asset.id)
                    )
                }
            }
            return try await group.reduce(into: [AssetBasic]()) { if let asset = $1 { $0.append(asset) } }
        }
    }
}
