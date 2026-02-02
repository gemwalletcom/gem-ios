// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StakeService
import YieldService

public struct EarnService: Sendable {
    public let stakeService: StakeService
    public let yieldService: any YieldServiceType

    public init(stakeService: StakeService, yieldService: any YieldServiceType) {
        self.stakeService = stakeService
        self.yieldService = yieldService
    }
}
