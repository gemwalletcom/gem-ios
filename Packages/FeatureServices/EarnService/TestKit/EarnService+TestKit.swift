// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import EarnService

public final class MockEarnService: EarnServiceable, @unchecked Sendable {
    public init() {}

    public func update(walletId: WalletId, assetId: AssetId, address: String) async throws {}
}

extension MockEarnService {
    public static func mock() -> MockEarnService {
        MockEarnService()
    }
}
