// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import FiatTransactionService
import GemAPITestKit
import StoreTestKit

public extension FiatTransactionService {
    static func mock() -> FiatTransactionService {
        FiatTransactionService(
            apiService: GemAPIFiatServiceMock(),
            store: .mock()
        )
    }
}
