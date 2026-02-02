// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StakeService
import StakeServiceTestKit
import YieldService

@testable import EarnService

public extension EarnService {
    static func mock(
        stakeService: StakeService = StakeService.mock(),
        yieldService: any YieldServiceType = MockYieldService()
    ) -> EarnService {
        EarnService(
            stakeService: stakeService,
            yieldService: yieldService
        )
    }
}
