// Copyright (c). Gem Wallet. All rights reserved.

import AssetsService
import BigInt
import Formatters
import Foundation
import GemstonePrimitives
import Primitives
import Store

public protocol EarnServiceable: Sendable {
    func update(walletId: WalletId, assetId: AssetId, address: String) async throws
}

public struct EarnService: EarnServiceable {
    private let assetsService: AssetsService
    private let assetStore: AssetStore
    private let balanceStore: BalanceStore
    private let store: StakeStore
    private let yieldService: YieldService
    private let formatter = ValueFormatter(style: .full)

    public init(
        assetsService: AssetsService,
        assetStore: AssetStore,
        balanceStore: BalanceStore,
        store: StakeStore,
        yieldService: YieldService
    ) {
        self.assetsService = assetsService
        self.assetStore = assetStore
        self.balanceStore = balanceStore
        self.store = store
        self.yieldService = yieldService
    }

    public func update(walletId: WalletId, assetId: AssetId, address: String) async throws {
        async let providers: Void = updateProviders(assetId: assetId)
        async let positions = fetchPositions(assetId: assetId, address: address)

        let (_, fetchedPositions) = try await (providers, positions)
        try updatePositions(walletId: walletId, assetId: assetId, positions: fetchedPositions)
        try updateBalance(walletId: walletId, assetId: assetId)
    }

    private func updateProviders(assetId: AssetId) async throws {
        let providers = try await yieldService.getProviders(for: assetId)
        try store.updateValidators(providers)

        if let maxApr = providers.map(\.apr).max(), maxApr > 0 {
            try assetStore.setEarnApr(assetId: assetId.identifier, apr: maxApr)
        }
    }

    private func fetchPositions(assetId: AssetId, address: String) async -> [DelegationBase] {
        await withTaskGroup(of: DelegationBase?.self) { group in
            for provider in YieldProvider.allCases {
                group.addTask {
                    try? await yieldService.fetchPosition(
                        provider: provider,
                        asset: assetId,
                        walletAddress: address
                    )
                }
            }
            var positions: [DelegationBase] = []
            for await position in group {
                if let position {
                    positions.append(position)
                }
            }
            return positions
        }
    }

    private func updatePositions(walletId: WalletId, assetId: AssetId, positions: [DelegationBase]) throws {
        let existingIds = try store
            .getDelegations(walletId: walletId, assetId: assetId, providerType: .earn)
            .map(\.id)
            .asSet()
        let positionIds = positions.map(\.id).asSet()
        let deleteIds = existingIds.subtracting(positionIds).asArray()

        try store.updateAndDelete(walletId: walletId, delegations: positions, deleteIds: deleteIds)
    }

    private func updateBalance(walletId: WalletId, assetId: AssetId) throws {
        let positions = try store.getDelegations(walletId: walletId, assetId: assetId, providerType: .earn)
        let total = positions
            .compactMap { BigInt($0.base.balance) }
            .reduce(.zero, +)
        guard let asset = try assetsService.getAssets(for: [assetId]).first else {
            throw AnyError("asset not found")
        }
        let amount = try formatter.double(from: total, decimals: asset.decimals.asInt)
        let update = UpdateBalance(
            assetId: assetId,
            type: .earn(UpdateEarnBalance(balance: UpdateBalanceValue(value: total.description, amount: amount))),
            updatedAt: .now,
            isActive: true
        )
        try balanceStore.updateBalances([update], for: walletId)
    }
}
