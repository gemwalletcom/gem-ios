// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import GemstonePrimitives
import NativeProviderService
import Primitives

public final class EarnService: EarnServiceType {
    public let yielder: GemYielder

    public init(yielder: GemYielder) {
        self.yielder = yielder
    }

    public convenience init(nodeProvider: any NodeURLFetchable) throws {
        let nativeProvider = NativeProvider(nodeProvider: nodeProvider)
        let yielder = try GemYielder(rpcProvider: nativeProvider)
        self.init(yielder: yielder)
    }

    public func getYields(for assetId: Primitives.AssetId) async throws -> [GemYield] {
        try await yielder.yieldsForAsset(assetId: assetId.identifier)
    }

    public func deposit(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        try await yielder.deposit(
            provider: provider.name,
            asset: asset.identifier,
            walletAddress: walletAddress,
            value: value
        )
    }

    public func withdraw(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        try await yielder.withdraw(
            provider: provider.name,
            asset: asset.identifier,
            walletAddress: walletAddress,
            value: value
        )
    }

    public func fetchPosition(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> GemYieldPosition {
        try await yielder.positions(
            provider: provider.name,
            asset: asset.identifier,
            walletAddress: walletAddress
        )
    }
}
