// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import GemstonePrimitives
import NativeProviderService
import Primitives

public final class EarnService: EarnServiceable {
    public let yielder: GemYielder

    public init(yielder: GemYielder) {
        self.yielder = yielder
    }

    public convenience init(nodeProvider: any NodeURLFetchable) throws {
        let nativeProvider = NativeProvider(nodeProvider: nodeProvider)
        let yielder = try GemYielder(rpcProvider: nativeProvider)
        self.init(yielder: yielder)
    }

    public func getProviders(for assetId: Primitives.AssetId) async throws -> [EarnProvider] {
        let yields = try await yielder.yieldsForAsset(assetId: assetId.identifier)
        return try yields.map { try $0.mapToEarnProvider() }
    }

    public func deposit(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        try await yielder.deposit(
            provider: provider.map(),
            asset: asset.identifier,
            walletAddress: walletAddress,
            value: value
        )
    }

    public func withdraw(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        try await yielder.withdraw(
            provider: provider.map(),
            asset: asset.identifier,
            walletAddress: walletAddress,
            value: value
        )
    }

    public func fetchPosition(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> GemEarnPositionBase {
        try await yielder.positions(
            provider: provider.map(),
            asset: asset.identifier,
            walletAddress: walletAddress
        )
    }
}
