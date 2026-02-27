// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService

public struct AssetsEnablerMock: AssetsEnabler {
    private let onEnableAssets: (@Sendable (Wallet, [AssetId], Bool) async throws -> Void)?

    public init(onEnableAssets: (@Sendable (Wallet, [AssetId], Bool) async throws -> Void)? = nil) {
        self.onEnableAssets = onEnableAssets
    }

    public func enableAssets(wallet: Wallet, assetIds: [AssetId], enabled: Bool) async throws {
        try await onEnableAssets?(wallet, assetIds, enabled)
    }

    public func enableAssetId(wallet: Wallet, assetId: AssetId) async throws {}
}

public extension AssetsEnabler where Self == AssetsEnablerMock {
    static func mock(
        onEnableAssets: (@Sendable (Wallet, [AssetId], Bool) async throws -> Void)? = nil
    ) -> AssetsEnablerMock {
        AssetsEnablerMock(onEnableAssets: onEnableAssets)
    }
}
