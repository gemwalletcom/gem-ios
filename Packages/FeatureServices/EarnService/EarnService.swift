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

    public func getProtocols(for assetId: Primitives.AssetId) async throws -> [EarnProtocol] {
        let protocols = try await yielder.yieldsForAsset(assetId: assetId.identifier)
        return try protocols.map { try $0.map() }
    }

    public func deposit(
        provider: EarnProvider,
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
        provider: EarnProvider,
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
        provider: EarnProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> EarnPosition {
        let position = try await yielder.positions(
            provider: provider.map(),
            asset: asset.identifier,
            walletAddress: walletAddress
        )
        guard let earnPosition = EarnPosition(position: position) else {
            throw AnyError("Earn position mapping failed")
        }
        return earnPosition
    }
}
