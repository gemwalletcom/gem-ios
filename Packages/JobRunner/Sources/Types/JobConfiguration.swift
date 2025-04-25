// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum JobConfiguration: Sendable {
    // Always wait the same fixed `Duration` between attempts.
    case fixed(
        duration: Duration,
        timeLimit: Duration? = nil
    )

    // Exponential back-off
    case adaptive(
        configuration: AdaptiveConfiguration,
        timeLimit: Duration? = nil
    )

    // auto-complete by time
    var timeLimit: Duration? {
        switch self {
        case let .fixed(_, time): time
        case let .adaptive(_, time): time
        }
    }
}
