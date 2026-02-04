// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

public protocol EarnServiceType: Sendable {
    func getProtocols(for assetId: Primitives.AssetId) async throws -> [EarnProtocol]

    func deposit(
        provider: EarnProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction

    func withdraw(
        provider: EarnProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction

    func fetchPosition(
        provider: EarnProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> EarnPosition
}
