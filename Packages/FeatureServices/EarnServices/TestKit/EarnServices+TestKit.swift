// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StakeService
import StakeServiceTestKit
import EarnService
import EarnServiceTestKit

@testable import EarnServices

public extension EarnServices {
    static func mock(
        stakeService: StakeService = StakeService.mock(),
        earnService: any EarnServiceable = MockEarnService()
    ) -> EarnServices {
        EarnServices(
            stakeService: stakeService,
            earnService: earnService
        )
    }
}
