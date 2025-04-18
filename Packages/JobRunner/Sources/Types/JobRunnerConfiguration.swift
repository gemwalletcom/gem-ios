// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum JobRunnerConfiguration: Sendable {
    // Always wait the same fixed `Duration` between attempts.
    case fixed(Duration)
    // Exponential back-off
    case adaptive(AdaptiveConfiguration)
}
