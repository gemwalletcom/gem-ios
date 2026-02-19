// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesTestKit
import EarnService

public final class MockEarnService: EarnDataProvidable, @unchecked Sendable {
    public init() {}

    public func getEarnData(chain: Chain, assetId: AssetId, address: String, value: String, earnType: EarnType) async throws -> EarnData {
        .mock()
    }
}

extension MockEarnService {
    public static func mock() -> MockEarnService {
        MockEarnService()
    }
}
