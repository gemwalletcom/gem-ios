// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import TransactionsService
import StoreTestKit
import AssetsServiceTestKit

public extension TransactionsService {
    static func mock() -> TransactionsService {
        TransactionsService(
            transactionStore: .mock(),
            assetsService: .mock(),
            walletStore: .mock()
        )
    }
}
