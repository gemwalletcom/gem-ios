// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletsService

public struct AssetDiscoveryServiceMock: AssetDiscoverable {
    public init() {}

    public func discoverAssets(wallet: Wallet) async throws {}
}

public extension AssetDiscoverable where Self == AssetDiscoveryServiceMock {
    static func mock() -> AssetDiscoveryServiceMock {
        AssetDiscoveryServiceMock()
    }
}
