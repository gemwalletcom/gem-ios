// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Formatters
import Foundation
import Primitives
import Store

internal import BigInt

public protocol EarnDataProvidable: Sendable {
    func getEarnData(assetId: AssetId, address: String, value: String, earnType: EarnType) async throws -> EarnData
}

public struct EarnService: Sendable {
    private let store: StakeStore
    private let balanceStore: BalanceStore
    private let gatewayService: GatewayService

    public init(store: StakeStore, balanceStore: BalanceStore, gatewayService: GatewayService) {
        self.store = store
        self.balanceStore = balanceStore
        self.gatewayService = gatewayService
    }

    public func update(walletId: WalletId, assetId: AssetId, address: String) async throws {
        let providers = await gatewayService.earnProviders(assetId: assetId)
        try store.updateValidators(providers)

        let positions = try await gatewayService.earnPositions(chain: assetId.chain, address: address, assetIds: [assetId])

        try updatePositions(walletId: walletId, assetId: assetId, positions: positions)
        try updateEarnBalance(walletId: walletId, assetId: assetId, positions: positions)
    }

    private func updatePositions(walletId: WalletId, assetId: AssetId, positions: [DelegationBase]) throws {
        let existingIds = try store
            .getDelegations(walletId: walletId, assetId: assetId, providerType: .earn)
            .map(\.id)
            .asSet()
        let deleteIds = existingIds.subtracting(positions.map(\.id).asSet()).asArray()

        try store.updateAndDelete(walletId: walletId, delegations: positions, deleteIds: deleteIds)
    }

    private func updateEarnBalance(walletId: WalletId, assetId: AssetId, positions: [DelegationBase]) throws {
        let balance = try getEarnUpdateBalance(assetId: assetId, positions: positions)
        try balanceStore.updateBalances([balance], for: walletId)
    }

    private func getEarnUpdateBalance(assetId: AssetId, positions: [DelegationBase]) throws -> UpdateBalance {
        let total = positions.reduce(BigInt.zero) { $0 + (BigInt($1.balance) ?? .zero) }
        let decimals = assetId.chain.asset.decimals.asInt
        let formatter = ValueFormatter.full
        let amount = try formatter.double(from: total, decimals: decimals)

        return UpdateBalance(
            assetId: assetId,
            type: .earn(UpdateEarnBalance(balance: UpdateBalanceValue(value: total.description, amount: amount))),
            updatedAt: .now,
            isActive: true
        )
    }
}

// MARK: - EarnDataProvidable

extension EarnService: EarnDataProvidable {
    public func getEarnData(assetId: AssetId, address: String, value: String, earnType: EarnType) async throws -> EarnData {
        try await gatewayService.getEarnData(assetId: assetId, address: address, value: value, earnType: earnType)
    }
}
