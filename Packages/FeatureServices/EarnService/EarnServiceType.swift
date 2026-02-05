// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public protocol EarnServiceable: Sendable {
    func getProviders(for assetId: Primitives.AssetId) async throws -> [EarnProvider]

    func deposit(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction

    func withdraw(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction

    func fetchPosition(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> GemEarnPositionBase
}
