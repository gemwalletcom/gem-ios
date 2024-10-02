import Foundation
import Store
import Primitives
import GemAPI
import Blockchain

class AssetsService {
    
    let assetStore: AssetStore
    let balanceStore: BalanceStore
    let assetsProvider: any GemAPIAssetsService
    let chainServiceFactory: ChainServiceFactory
    
    init(
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
    public func addAsset(walletId: WalletId, asset: Asset) throws {
        try addAssets(assets: [
            AssetFull(asset: asset, details: .none, price: .none, market: .none, score: AssetScore(rank: 10))
        ])
        try addBalanceIfMissing(walletId: walletId, assetId: asset.id)
        try updateEnabled(walletId: walletId, assetId: asset.id, enabled: true)
    }
    
    public func addAssets(assets: [AssetFull]) throws {
        return try assetStore.insertFull(assets: assets)
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

    public func getAssets(for assetIds: [AssetId]) throws -> [Asset] {
        return try assetStore.getAssets(for: assetIds.ids)
    }
    
    func getAssets(walletID: String, filters: [AssetsRequestFilter]) throws -> [AssetData] {
        try assetStore.getAssetsData(for: walletID, filters: filters)
    }
    
    func addBalancesIfMissing(walletId: WalletId, assetIds: [AssetId]) throws {
        for assetId in assetIds {
            try addBalanceIfMissing(walletId: walletId, assetId: assetId)
        }
    }
    
    func addBalanceIfMissing(walletId: WalletId, assetId: AssetId) throws {
        let exist = try balanceStore.isBalanceExist(walletId: walletId.id, assetId: assetId.identifier)
        if !exist {
            let balance = AddBalance(assetId: assetId.identifier, isEnabled: false)
            try balanceStore.addBalance([balance], for: walletId.id)
        }
    }
    
    func updateEnabled(walletId: WalletId, assetId: AssetId, enabled: Bool) throws {
        try balanceStore.setIsEnabled(walletId: walletId.id, assetIds: [assetId.identifier], value: enabled)
    }
    
    func updateAsset(assetId: AssetId) async throws {
        let details = try await getAsset(assetId: assetId)
        try assetStore.insertFull(assets: [details])
        try assetStore.updateDetails(details)
    }
    
    func getAsset(assetId: AssetId) async throws -> AssetFull {
        try await assetsProvider
            .getAsset(assetId: assetId)
    }

    func getAssets(assetIds: [AssetId]) async throws -> [AssetFull] {
        try await assetsProvider
            .getAssets(assetIds: assetIds)
    }
    
    // search
    
    func searchAssets(query: String, chains: [Chain]) async throws -> [AssetFull] {
        let assets = try await withThrowingTaskGroup(of: [AssetFull]?.self) { group in
            var assets = [AssetFull]()
            
            group.addTask {
                return try await self.searchAPIAssets(query: query, chains: chains)
            }
            group.addTask {
                return try await self.searchNetworkAsset(tokenId: query, chains: chains.isEmpty ? Chain.allCases : chains)
            }
            
            for try await result in group {
                if let result = result {
                    assets.append(contentsOf: result)
                }
            }
            return assets
        }
        return assets.sorted { l, r in
            l.score.rank > r.score.rank
        }
    }
    
    func searchAPIAssets(query: String, chains: [Chain]) async throws -> [AssetFull] {
        return try await assetsProvider.getSearchAssets(query: query, chains: chains)
    }
    
    @discardableResult
    func prefetchAssets(assetIds: [AssetId]) async throws -> [AssetId] {
        let assets = try getAssets(for: assetIds).map { $0.id }.asSet()
        let missingAssetIds = assetIds.asSet().subtracting(assets)
        
        // add missing assets to local storage
        let newAssets = try await getAssets(assetIds: missingAssetIds.asArray())
        try addAssets(assets: newAssets)
        
        return newAssets.map { $0.asset.id }
    }
    
    func searchNetworkAsset(tokenId: String, chains: [Chain]) async throws -> [AssetFull] {
        let services = chains.map {
            chainServiceFactory.service(for: $0)
        }.filter {
            $0.getIsTokenAddress(tokenId: tokenId)
        }
        
        let assets = try await withThrowingTaskGroup(of: Asset?.self) { group in
            var assets = [Asset]()
            services.forEach { service in
                group.addTask {
                    try? await service.getTokenData(tokenId: tokenId)
                }
            }
            for try await asset in group {
                if let asset = asset {
                    assets.append(asset)
                }
            }
            return assets
        }
        
        return assets.map {
            AssetFull(
                asset: $0,
                details: .none,
                price: .none,
                market: .none,
                score: AssetScore(rank: 12)
            )
        }
    }
}
