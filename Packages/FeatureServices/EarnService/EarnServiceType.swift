// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public protocol EarnServiceType: Sendable {
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
}
