// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Combine
import Store
import ChainService

public final class BalanceService: BalancerUpdater, Sendable {
    private let balanceStore: BalanceStore
    private let assersStore: AssetStore

    private let chainServiceFactory: ChainServiceFactory
    private let formatter = ValueFormatter(style: .full)

    public init(
        balanceStore: BalanceStore,
        assertStore: AssetStore,
        chainServiceFactory: ChainServiceFactory
    ) {
        self.balanceStore = balanceStore
        self.assersStore = assertStore
        self.chainServiceFactory = chainServiceFactory
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

    public func updateBalance(walletId: String, asset: AssetId, address: String) async {
        switch asset.type {
        case .native:
            await updateCoinBalance(walletId: walletId, asset: asset, address: address)
        case .token:
            await updateTokenBalances(walletId: walletId, chain: asset.chain, tokenIds: [asset], address: address)
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

    public func addAssetsBalancesIfMissing(assetIds: [AssetId], wallet: Wallet) throws {
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

    // MARK: - Private

    private func addBalance(walletId: String, balances: [AddBalance]) throws {
        try balanceStore.addBalance(balances, for: walletId)
    }

    private func getWalletBalances(assetIds: [String]) throws -> [WalletAssetBalance] {
        try balanceStore.getBalances(assetIds: assetIds)
    }

    private func updateCoinBalance(walletId: String, asset: AssetId, address: String) async {
        let chain = asset.chain
        await updateBalanceAsync(
            walletId: walletId,
            chain: chain,
            fetchBalance: { [try await getCoinBalance(chain: chain, address: address).coinChange] },
            mapBalance: { $0 }
        )
    }

    private func updateCoinStakeBalance(walletId: String, asset: AssetId, address: String) async {
        let chain = asset.chain
        await updateBalanceAsync(
            walletId: walletId,
            chain: chain,
            fetchBalance: { [try await getCoinStakeBalance(chain: chain, address: address)?.stakeChange] },
            mapBalance: { $0 }
        )
    }

    private func updateTokenBalances(walletId: String, chain: Chain, tokenIds: [AssetId], address: String) async {
        await updateBalanceAsync(
            walletId: walletId,
            chain: chain,
            fetchBalance: { try await getTokenBalance(chain: chain, address: address, tokenIds: tokenIds.ids) },
            mapBalance: { $0.tokenChange }
        )
    }

    private func updateBalanceAsync<T>(
        walletId: String,
        chain: Chain,
        fetchBalance: () async throws -> [T],
        mapBalance: (T) -> AssetBalanceChange?
    ) async {
        do {
            let balances = try await fetchBalance().compactMap { mapBalance($0) }
            try storeBalances(balances: balances, walletId: walletId)
        } catch {
            NSLog("update balance error: chain: \(chain.id): \(error.localizedDescription)")
        }
    }

    private func getCoinBalance(chain: Chain, address: String) async throws -> AssetBalance {
        try await chainServiceFactory.service(for: chain)
            .coinBalance(for: address)
    }

    private func getCoinStakeBalance(chain: Chain, address: String) async throws -> AssetBalance? {
        try await chainServiceFactory.service(for: chain)
            .getStakeBalance(for: address)
    }

    private func getTokenBalance(chain: Chain, address: String, tokenIds: [String]) async throws -> [AssetBalance] {
        try await chainServiceFactory.service(for: chain)
           .tokenBalance(for: address, tokenIds: tokenIds.compactMap { try? AssetId(id: $0) })
    }

    private func createUpdateBalanceType(asset: Asset, change: AssetBalanceChange) throws -> UpdateBalanceType {
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

    private func storeBalances(balances: [AssetBalanceChange], walletId: String) throws {
        for balance in balances {
            NSLog("update balance: \(balance.assetId.identifier): \(balance.type)")
        }
        let assetIds = balances.map { $0.assetId }
        let assets = try assersStore.getAssets(for: assetIds.ids)
        let updates = createBalanceUpdate(assets: assets, balances: balances)

        try updateBalances(updates, walletId: walletId)
    }

    private func createBalanceUpdate(assets: [Asset], balances: [AssetBalanceChange]) -> [UpdateBalance] {
        let assets = assets.toMap { $0.id.identifier }
        return balances.compactMap { balance in
            guard
                let asset = assets[balance.assetId.identifier],
                let update = try? createUpdateBalanceType(asset: asset, change: balance) else {
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
        try balanceStore.updateBalances(balances, for: walletId)
    }
}

