// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public protocol YieldServiceType: Sendable {
    func getYields(for assetId: Primitives.AssetId) async throws -> [GemYield]

    func deposit(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction

    func withdraw(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction

    func fetchPosition(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> GemYieldPosition

    @discardableResult
    func getPosition(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        walletId: WalletId,
        onUpdate: (@MainActor @Sendable (GemYieldPosition) -> Void)?
    ) -> GemYieldPosition?

    func clearPosition(provider: GemYieldProvider, walletId: WalletId, assetId: Primitives.AssetId)

    func clear() throws
}
