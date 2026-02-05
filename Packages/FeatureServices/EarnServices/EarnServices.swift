// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StakeService
import EarnService

public struct EarnServices: Sendable {
    public let stakeService: StakeService
    public let earnService: any EarnServiceable

    public init(stakeService: StakeService, earnService: any EarnServiceable) {
        self.stakeService = stakeService
        self.earnService = earnService
    }
}
