// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DiscoverAssetsService
import BalanceService
import BalanceServiceTestKit

public extension DiscoverAssetsService {
    static func mock(
        balanceService: BalanceService = .mock()
    ) -> DiscoverAssetsService {
        DiscoverAssetsService(
            balanceService: balanceService
        )
    }
}
