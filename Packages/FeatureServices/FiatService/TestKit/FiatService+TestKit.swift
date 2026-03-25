// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import FiatService
import GemAPITestKit
import StoreTestKit

public extension FiatService {
    static func mock() -> FiatService {
        FiatService(
            apiService: GemAPIFiatServiceMock(),
            store: .mock()
        )
    }
}
