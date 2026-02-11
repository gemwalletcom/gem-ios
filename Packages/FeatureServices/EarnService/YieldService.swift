// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import GemstonePrimitives
import NativeProviderService
import Primitives

public final class YieldService: Sendable {
    private let yielder: GemYielder

    public init(yielder: GemYielder) {
        self.yielder = yielder
    }

    public convenience init(nodeProvider: any NodeURLFetchable) {
        // TODO: - review core force unwrapping
        try! self.init(yielder: GemYielder(rpcProvider: NativeProvider(nodeProvider: nodeProvider)))
    }

    public func getProviders(for assetId: Primitives.AssetId) async throws -> [DelegationValidator] {
        try await yielder.yieldsForAsset(assetId: assetId.identifier)
            .map { try $0.map() }
    }

    public func deposit(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> EarnTransaction {
        try await yielder.deposit(
            provider: provider.map(),
            asset: asset.identifier,
            walletAddress: walletAddress,
            value: value
        ).map()
    }

    public func withdraw(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> EarnTransaction {
        try await yielder.withdraw(
            provider: provider.map(),
            asset: asset.identifier,
            walletAddress: walletAddress,
            value: value
        ).map()
    }

    public func fetchPosition(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> DelegationBase {
        try await yielder.positions(
            provider: provider.map(),
            asset: asset.identifier,
            walletAddress: walletAddress
        ).map()
    }
}
