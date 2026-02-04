// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StakeService
import EarnService

public struct EarnServices: Sendable {
    public let stakeService: StakeService
    public let earnService: any EarnServiceType

    public init(stakeService: StakeService, earnService: any EarnServiceType) {
        self.stakeService = stakeService
        self.earnService = earnService
    }
}
