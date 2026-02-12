// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Foundation
import Primitives
import Store

public protocol EarnServiceable: Sendable {
    func update(walletId: WalletId, assetId: AssetId, address: String) async throws
}

public struct EarnService: EarnServiceable {
    private let assetStore: AssetStore
    private let store: StakeStore
    private let gatewayService: GatewayService

    public init(
        assetStore: AssetStore,
        store: StakeStore,
        gatewayService: GatewayService
    ) {
        self.assetStore = assetStore
        self.store = store
        self.gatewayService = gatewayService
    }

    public func update(walletId: WalletId, assetId: AssetId, address: String) async throws {
        async let providers: Void = updateProviders(assetId: assetId)
        async let positions = fetchPositions(chain: assetId.chain, address: address)

        let (_, fetchedPositions) = try await (providers, positions)
        try updatePositions(walletId: walletId, assetId: assetId, positions: fetchedPositions)
    }

    private func updateProviders(assetId: AssetId) async throws {
        let providers = try await gatewayService.earnProviders(assetId: assetId)
        try store.updateValidators(providers)

        if let maxApr = providers.map(\.apr).max(), maxApr > 0 {
            try assetStore.setEarnApr(assetId: assetId.identifier, apr: maxApr)
        }
    }

    private func fetchPositions(chain: Chain, address: String) async throws -> [DelegationBase] {
        try await gatewayService.earnPositions(chain: chain, address: address)
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
}
