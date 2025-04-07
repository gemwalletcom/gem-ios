// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct PollResult: Sendable {
    let isActive: Bool
    let recommendedInterval: Duration

    init(
        isActive: Bool,
        recommendedInterval: Duration
    ) {
        self.isActive = isActive
        self.recommendedInterval = recommendedInterval
    }
}
