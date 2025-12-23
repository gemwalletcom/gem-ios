// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import ChainService
import Formatters
import AssetsService

public struct BalanceService: BalancerUpdater, Sendable {
    private let balanceStore: BalanceStore
    private let assetsService: AssetsService
    private let fetcher: BalanceFetcher
    private let formatter = ValueFormatter(style: .full)

    public init(
        balanceStore: BalanceStore,
        assetsService: AssetsService,
        chainServiceFactory: ChainServiceFactory
    ) {
        self.balanceStore = balanceStore
        self.assetsService = assetsService
        self.fetcher = BalanceFetcher(chainServiceFactory: chainServiceFactory)
    }
}

// MARK: - Asset Manage

extension BalanceService {
    public func hideAsset(walletId: WalletId, assetId: AssetId) throws {
        try balanceStore.setIsEnabled(walletId: walletId.id, assetIds: [assetId.identifier], value: false)
    }

    public func pinAsset(walletId: WalletId, assetId: AssetId) throws {
        try balanceStore.pinAsset(walletId: walletId.id, assetId: assetId.identifier, value: true)
    }

    public func unpinAsset(walletId: WalletId, assetId: AssetId) throws {
        try balanceStore.pinAsset(walletId: walletId.id, assetId: assetId.identifier, value: false)
    }
}

// MARK: - Balances

extension BalanceService {

    public func getBalance(walletId: String, assetId: String) throws -> Balance? {
        try balanceStore.getBalance(walletId: walletId, assetId: assetId)
    }

    public func getBalance(assetId: AssetId, address: String) async throws -> AssetBalance  {
        try await fetcher.getBalance(assetId: assetId, address: address)
    }

    @discardableResult
    public func updateBalance(walletId: String, asset: AssetId, address: String) async throws -> [AssetBalanceChange] {
        switch asset.type {
        case .native:
            await updateCoinBalance(walletId: walletId, asset: asset, address: address)
        case .token:
            await updateTokenBalances(walletId: walletId, chain: asset.chain, tokenIds: [asset], address: address)
        }
    }

    public func updateBalance(for wallet: Wallet, assetIds: [AssetId]) async {
        await withTaskGroup(of: Void.self) { group in
            for account in wallet.accounts {
                let chain = account.chain
                let address = account.address
                let ids = assetIds.filter { $0.identifier.hasPrefix(chain.rawValue) }
                let tokenIds = ids.filter { $0.identifier != chain.id }

                guard !ids.isEmpty else { continue }

                // coin balance
                if ids.contains(chain.assetId) {
                    group.addTask {
                        await updateCoinBalance(walletId: wallet.id, asset: chain.assetId, address: address)
                    }
                    group.addTask {
                        await updateCoinStakeBalance(walletId: wallet.id, asset: chain.assetId, address: address)
                    }
                }

                // token balance
                if !tokenIds.isEmpty {
                    group.addTask {
                        await updateTokenBalances(walletId: wallet.id, chain: chain, tokenIds: tokenIds, address: address)
                    }
                }
            }

            for await _ in group { }
        }
    }

    public func addAssetsBalancesIfMissing(assetIds: [AssetId], wallet: Wallet, isEnabled: Bool?) throws {
        let balancesAssetIds = try balanceStore
            .getBalances(walletId: wallet.id, assetIds: assetIds.ids)
            .map { $0.assetId }
        let missingBalancesAssetIds = assetIds.asSet().subtracting(balancesAssetIds)

        try addBalance(
            walletId: wallet.id,
            balances: missingBalancesAssetIds.map {
                AddBalance(
                    assetId: $0,
                    isEnabled: isEnabled ?? false
                )
            }
        )
    }

    // MARK: - Private Helpers

    private func addBalance(walletId: String, balances: [AddBalance]) throws {
        try balanceStore.addBalance(balances, for: walletId)
    }

    private func getWalletBalances(assetIds: [String]) throws -> [WalletAssetBalance] {
        try balanceStore.getBalances(assetIds: assetIds)
    }

    @discardableResult
    private func updateCoinBalance(walletId: String, asset: AssetId, address: String) async -> [AssetBalanceChange] {
        let chain = asset.chain
        return await updateBalanceAsync(
            walletId: walletId,
            chain: chain,
            fetchBalance: { [try await fetcher.getCoinBalance(chain: chain, address: address).coinChange] },
            mapBalance: { $0 }
        )
    }

    @discardableResult
    private func updateCoinStakeBalance(walletId: String, asset: AssetId, address: String) async -> [AssetBalanceChange] {
        let chain = asset.chain
        return await updateBalanceAsync(
            walletId: walletId,
            chain: chain,
            fetchBalance: { [try await fetcher.getCoinStakeBalance(chain: chain, address: address)?.stakeChange] },
            mapBalance: { $0 }
        )
    }

    @discardableResult
    private func updateTokenBalances(walletId: String, chain: Chain, tokenIds: [AssetId], address: String) async -> [AssetBalanceChange] {
        await updateBalanceAsync(
            walletId: walletId,
            chain: chain,
            fetchBalance: { try await fetcher.getTokenBalance(chain: chain, address: address, tokenIds: tokenIds.ids)
            },
            mapBalance: { $0.tokenChange }
        )
    }

    private func updateBalanceAsync<T: Sendable>(
        walletId: String,
        chain: Chain,
        fetchBalance: () async throws -> [T],
        mapBalance: (T) -> AssetBalanceChange?
    ) async -> [AssetBalanceChange] {
        do {
            let balances = try await fetchBalance().compactMap { mapBalance($0) }
            try await addAssetsIfNeeded(balances: balances)
            try storeBalances(balances: balances, walletId: walletId)
            return balances
        } catch {
            debugLog("update balance error: chain: \(chain.id): \(error.localizedDescription)")
            return []
        }
    }

    private func createUpdateBalanceType(asset: Asset, change: AssetBalanceChange) throws -> UpdateBalanceType {
        let decimals = asset.decimals.asInt
        switch change.type {
        case .coin(let available, let reserved, let pendingUnconfirmed):
            let availableValue = try UpdateBalanceValue(
                value: available.description,
                amount: formatter.double(from: available, decimals: decimals)
            )
            let reservedValue = try UpdateBalanceValue(
                value: reserved.description,
                amount: formatter.double(from: reserved, decimals: decimals)
            )
            let pendingUnconfirmedValue = try UpdateBalanceValue(
                value: pendingUnconfirmed.description,
                amount: formatter.double(from: pendingUnconfirmed, decimals: decimals)
            )
            return .coin(UpdateCoinBalance(available: availableValue, reserved: reservedValue, pendingUnconfirmed: pendingUnconfirmedValue))
        case .token(let available):
            let available = try UpdateBalanceValue(
                value: available.description,
                amount: formatter.double(from: available, decimals: decimals)
            )
            return .token(UpdateTokenBalance(available: available))
        case .stake(let staked, let pending, let rewards, _, let locked, let frozen, let metadata):
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
                    rewards: rewardsValue,
                    metadata: metadata
                )
            )
        }
    }

    private func storeBalances(balances: [AssetBalanceChange], walletId: String) throws {
        for balance in balances {
            debugLog("update balance: \(balance.assetId.identifier): \(balance.type)")
        }
        let assets = try assetsService.getAssets(for: balances.map { $0.assetId })
        let updates = createBalanceUpdate(assets: assets, balances: balances)

        try updateBalances(updates, walletId: walletId)
    }

    private func createBalanceUpdate(assets: [Asset], balances: [AssetBalanceChange]) -> [UpdateBalance] {
        let assets = assets.toMap { $0.id.identifier }
        return balances.compactMap { balance in
            guard
                let asset = assets[balance.assetId.identifier],
                let update = try? createUpdateBalanceType(asset: asset, change: balance)
            else {
                return .none
            }
            return UpdateBalance(
                assetID: balance.assetId.identifier,
                type: update,
                updatedAt: .now,
                isActive: balance.isActive
            )
        }
    }

    private func updateBalances(_ balances: [UpdateBalance], walletId: String) throws {
        let assetIds = balances.map { $0.assetID }
        let existBalances = try balanceStore.getBalances(walletId: walletId, assetIds: assetIds)
        let missingBalances = assetIds.asSet().subtracting(existBalances.map { $0.assetId.identifier }).asArray()
        let addBalances: [AddBalance] = try missingBalances.map {
            AddBalance(assetId: try AssetId(id: $0), isEnabled: false)
        }

        try balanceStore.addBalance(addBalances, for: walletId)
        try balanceStore.updateBalances(balances, for: walletId)
    }
    
    private func addAssetsIfNeeded(balances: [AssetBalanceChange]) async throws {
        let assetIds = balances.map { $0.assetId }
        let existAssets = try assetsService.getAssets(for: assetIds)
        let missingIds = assetIds.asSet().subtracting(existAssets.map { $0.id }).asArray()
        if missingIds.isNotEmpty {
            try await assetsService.addAssets(assetIds: missingIds)
        }
    }
}
