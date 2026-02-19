// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Foundation
import Primitives
import Store

public protocol EarnDataProvidable: Sendable {
    func getEarnData(chain: Chain, assetId: AssetId, address: String, value: String, earnType: EarnType) async throws -> EarnData
}

public struct EarnService: Sendable {
    private let store: StakeStore
    private let gatewayService: GatewayService

    public init(store: StakeStore, gatewayService: GatewayService) {
        self.store = store
        self.gatewayService = gatewayService
    }

    public func update(walletId: WalletId, assetId: AssetId, address: String) async throws {
        async let providers: Void = updateProviders(assetId: assetId)
        async let positions = gatewayService.earnPositions(chain: assetId.chain, address: address)

        let (_, fetched) = try await (providers, positions)
        try updatePositions(walletId: walletId, assetId: assetId, positions: fetched)
    }

    private func updateProviders(assetId: AssetId) async throws {
        let providers = try await gatewayService.earnProviders(assetId: assetId)
        try store.updateValidators(providers)
    }

    private func updatePositions(walletId: WalletId, assetId: AssetId, positions: [DelegationBase]) throws {
        let existingIds = try store
            .getDelegations(walletId: walletId, assetId: assetId, providerType: .earn)
            .map(\.id)
            .asSet()
        let deleteIds = existingIds.subtracting(positions.map(\.id).asSet()).asArray()
        try store.updateAndDelete(walletId: walletId, delegations: positions, deleteIds: deleteIds)
    }
}

// MARK: - EarnDataProvidable

extension EarnService: EarnDataProvidable {
    public func getEarnData(chain: Chain, assetId: AssetId, address: String, value: String, earnType: EarnType) async throws -> EarnData {
        try await gatewayService.getEarnData(chain: chain, assetId: assetId, address: address, value: value, earnType: earnType)
    }
}
