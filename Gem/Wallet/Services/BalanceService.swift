// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Combine
import Store
import Blockchain
import Settings
import ChainService

public struct BalanceUpdate {
    public let walletId: String
    public let balances: [AssetBalanceChange]
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
        await updateBalanceAsync(
            walletId: walletId,
            chain: chain,
            fetchBalance: { [try await getCoinBalance(chain: chain, address: address).coinChange] },
            mapBalance: { $0 }
        )
    }

    public func updateCoinStakeBalance(walletId: String, asset: AssetId, address: String) async {
        let chain = asset.chain
        await updateBalanceAsync(
            walletId: walletId,
            chain: chain,
            fetchBalance: { [try await getCoinStakeBalance(chain: chain, address: address)?.stakeChange] },
            mapBalance: { $0 }
        )
    }

    public func updateTokenBalances(walletId: String, chain: Chain, tokenIds: [AssetId], address: String) async {
        await updateBalanceAsync(
            walletId: walletId,
            chain: chain,
            fetchBalance: { try await getTokenBalance(chain: chain, address: address, tokenIds: tokenIds.ids) },
            mapBalance: { $0.tokenChange }
        )
    }
    
    public func updateBalanceAsync<T>(
        walletId: String,
        chain: Chain,
        fetchBalance: () async throws -> [T],
        mapBalance: (T) -> AssetBalanceChange?
    ) async {
        do {
            let balances = try await fetchBalance().compactMap { mapBalance($0) }
            balanceSubject.send(BalanceUpdate(walletId: walletId, balances: balances))
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
                Task {
                    await updateCoinStakeBalance(walletId: wallet.id, asset: chain.assetId, address: address)
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
    
    func getCoinStakeBalance(chain: Chain, address: String) async throws -> AssetBalance? {
        return try await chainServiceFactory.service(for: chain)
            .getStakeBalance(for: address)
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
    
    func createUpdateBalanceType(asset: Asset, change: AssetBalanceChange) throws -> UpdateBalanceType {
        let decimals = asset.decimals.asInt
        switch change.type {
        case .coin(let available, let reserved):
            let available = try UpdateBalanceValue(
                value: available.description,
                amount: formatter.double(from: available, decimals: decimals)
            )
            let reservedValue = try UpdateBalanceValue(
                value: reserved.description,
                amount: formatter.double(from: reserved, decimals: decimals)
            )
            return .coin(UpdateCoinBalance(available: available, reserved: reservedValue))
        case .token(let available):
            let available = try UpdateBalanceValue(
                value: available.description,
                amount: formatter.double(from: available, decimals: decimals)
            )
            return .token(UpdateTokenBalance(available: available))
        case .stake(let staked, let pending, let rewards, _, let locked, let frozen):
            let stakedValue = try UpdateBalanceValue(
                value: staked.description,
                amount: formatter.double(from: staked, decimals: decimals)
            )
            let pendingValue = try UpdateBalanceValue(
                value: pending.description,
                amount: formatter.double(from: pending, decimals: decimals)
            )
            let frozenValue = try UpdateBalanceValue(
                value: frozen.description,
                amount: formatter.double(from: frozen, decimals: decimals)
            )
            let lockedValue = try UpdateBalanceValue(
                value: locked.description,
                amount: formatter.double(from: locked, decimals: decimals)
            )
            let rewardsValue = try UpdateBalanceValue(
                value: rewards.description,
                amount: formatter.double(from: rewards, decimals: decimals)
            )
            return .stake(
                UpdateStakeBalance(
                    staked: stakedValue,
                    pending: pendingValue,
                    frozen: frozenValue,
                    locked: lockedValue,
                    rewards: rewardsValue
                )
            )
        }
    }
    
    func createBalanceUpdate(assets: [Asset], balances: [AssetBalanceChange]) -> [UpdateBalance] {
        let assets = assets.toMap { $0.id.identifier }
        return balances.compactMap { balance in
            guard
                let asset = assets[balance.assetId.identifier],
                let update = try? createUpdateBalanceType(asset: asset, change: balance) else {
                    return .none
            }
            return UpdateBalance(assetID: balance.assetId.identifier, type: update, updatedAt: Date())
        }
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
