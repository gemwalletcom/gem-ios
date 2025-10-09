// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import TransactionsService
import StoreTestKit
import AssetsServiceTestKit
import DeviceServiceTestKit

public extension TransactionsService {
    static func mock() -> TransactionsService {
        TransactionsService(
            transactionStore: .mock(),
            assetsService: .mock(),
            walletStore: .mock(),
            deviceService: DeviceServiceMock(),
            addressStore: .mock()
        )
    }
}
