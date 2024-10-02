import Foundation
import Primitives
import Combine
import Store
import Blockchain
import Settings

public struct BalanceUpdate {
    public let walletId: String
    public let balances: [AssetBalance]
}

public struct BalanceUpdateError {
    public let chain: Chain
    public let error: any Error
}

public protocol BalancerUpdater {
    func updateBalance(walletId: String, asset: AssetId, address: String) async
}

public final class BalanceService: BalancerUpdater {
    
    private let balanceStore: BalanceStore
    private let chainServiceFactory: ChainServiceFactory
    private let formatter = ValueFormatter(style: .full)
    private var balanceSubject = PassthroughSubject<BalanceUpdate, Never>()
    private var balanceErrorsSubject = PassthroughSubject<BalanceUpdateError, Never>()
    
    public init(
        balanceStore: BalanceStore,
        chainServiceFactory: ChainServiceFactory
    ) {
        self.balanceStore = balanceStore
        self.chainServiceFactory = chainServiceFactory
    }
    
    public func addBalance(walletId: String, balances: [AddBalance]) throws {
        return try balanceStore.addBalance(balances, for: walletId)
    }
    
    public func getBalance(walletId: String, assetId: String) throws -> Balance? {
        return try balanceStore.getBalance(walletId: walletId, assetId: assetId)
    }
    
    public func getBalance(assetId: AssetId, address: String) async throws -> AssetBalance  {
        switch assetId.type {
        case .native:
            return try await getCoinBalance(chain: assetId.chain, address: address)
        case .token:
            guard let balance = try await getTokenBalance(chain: assetId.chain, address: address, tokenIds: [assetId.identifier]).first else {
                throw AnyError("no balance available")
            }
            return balance
        }
    }
    
    public func getWalletBalances(assetIds: [String]) throws -> [WalletAssetBalance] {
        return try balanceStore.getBalances(assetIds: assetIds)
    }
    
    public func updateBalances(_ balances: [UpdateBalance], walletId: String) throws {
        return try balanceStore.updateBalances(balances, for: walletId)
    }
    
    public func updateBalance(walletId: String, asset: AssetId, address: String) async {
        switch asset.type {
        case .native:
            return await updateCoinBalance(walletId: walletId, asset: asset, address: address)
        case .token:
            return await updateTokenBalances(walletId: walletId, chain: asset.chain, tokenIds: [asset], address: address)
        }
    }
    
    public func updateCoinBalance(walletId: String, asset: AssetId, address: String) async {
        let chain = asset.chain
        do {
            let balance = try await getCoinBalance(chain: chain, address: address)
            balanceSubject.send(BalanceUpdate(walletId: walletId,  balances: [balance]))
        } catch {
            balanceErrorsSubject.send(BalanceUpdateError(chain: chain, error: error))
        }
    }
    
    public func updateTokenBalances(walletId: String, chain: Chain, tokenIds: [AssetId], address: String) async {
        do {
            let balances = try await getTokenBalance(chain: chain, address: address, tokenIds: tokenIds.ids)
            balanceSubject.send(BalanceUpdate(walletId: walletId,  balances: balances))
        } catch {
            balanceErrorsSubject.send(BalanceUpdateError(chain: chain, error: error))
        }
    }
    
    public func updateBalance(for wallet: Wallet, assetIds: [AssetId]) {
        for account in wallet.accounts {
            let chain = account.chain
            let address = account.address
            let ids = assetIds.filter { $0.identifier.hasPrefix(chain.rawValue) }
            let tokenIds = ids.filter { $0.identifier != chain.id }
            
            guard !ids.isEmpty else {
                continue
            }
            // coin balance
            if ids.contains(chain.assetId) {
                Task {
                    await updateCoinBalance(walletId: wallet.id, asset: chain.assetId, address: address)
                }
            }
            // token balance
           if !tokenIds.isEmpty {
                Task {
                    await updateTokenBalances(walletId: wallet.id, chain: chain, tokenIds: tokenIds, address: address)
                }
            }
        }
    }
    
    func getCoinBalance(chain: Chain, address: String) async throws -> AssetBalance {
        return try await chainServiceFactory.service(for: chain)
            .coinBalance(for: address)
    }
    
    func getTokenBalance(chain: Chain, address: String, tokenIds: [String]) async throws -> [AssetBalance] {
        return try await chainServiceFactory.service(for: chain)
           .tokenBalance(for: address, tokenIds: tokenIds.compactMap { try? AssetId(id: $0) })
    }
    
    public func observeBalance() -> AnyPublisher<BalanceUpdate, Never> {
        return balanceSubject.eraseToAnyPublisher()
    }
    
    public func observeBalanceErrors() -> AnyPublisher<BalanceUpdateError, Never> {
        return balanceErrorsSubject.eraseToAnyPublisher()
    }
    
    func createBalanceUpdate(assets: [Asset], balances: [AssetBalance], prices: [AssetPrice]) -> [UpdateBalance] {
        let assets = assets.toMap { $0.id.identifier }
        let prices = prices.toMap { $0.assetId }
        
        return balances.compactMap { (balance: AssetBalance) in
            guard
                let asset = assets[balance.assetId.identifier],
                let total = try? formatter.double(from: balance.balance.total(asset.chain.includeStakedBalance), decimals: asset.decimals.asInt)
            else {
                return nil
            }
            let price = prices[balance.assetId.identifier]
            let fiatValue = total * (price?.price ?? 0)

            return updateBalance(balance: balance, total: total, fiatValue: fiatValue)
        }
    }
    
    private func updateBalance(balance: AssetBalance, total: Double, fiatValue: Double) -> UpdateBalance {
        return UpdateBalance(
            assetID: balance.assetId.identifier,
            available: balance.balance.available.description,
            frozen: balance.balance.frozen.description,
            locked: balance.balance.locked.description,
            staked: balance.balance.staked.description,
            pending: balance.balance.pending.description,
            reserved: balance.balance.reserved.description,
            total: total,
            fiatValue: fiatValue,
            updatedAt: Date()
        )
    }
    
    func addAssetsBalancesIfMissing(assetIds: [AssetId], wallet: Wallet) throws {
        let balancesAssetIds = try balanceStore
            .getBalances(walletId: wallet.id, assetIds: assetIds.ids)
            .map { $0.assetId }
        
        let missingBalancesAssetIds = assetIds.asSet()
            .subtracting(balancesAssetIds)
        
        try addBalance(
            walletId: wallet.id,
            balances: missingBalancesAssetIds.map {
                AddBalance(
                    assetId: $0.identifier,
                    isEnabled: AssetConfiguration.enabledByDefault.contains($0) || !wallet.isMultiCoins
                )
            }
        )
    }
    
    func hideAsset(walletId: WalletId, assetId: AssetId) throws {
        try balanceStore.setIsEnabled(walletId: walletId.id, assetIds: [assetId.identifier], value: false)
    }

    func pinAsset(walletId: WalletId, assetId: AssetId) throws {
        try balanceStore.pinAsset(walletId: walletId.id, assetId: assetId.identifier, value: true)
    }

    func unpinAsset(walletId: WalletId, assetId: AssetId) throws {
        try balanceStore.pinAsset(walletId: walletId.id, assetId: assetId.identifier, value: false)
    }
}
