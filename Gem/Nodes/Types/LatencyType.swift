// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum LatencyType: Sendable {
    case fast
    case normal
    case slow

    static func from(duration: Double) -> LatencyType {
        switch duration {
        case ..<1024:
            return .fast
        case ..<2048:
            return .normal
        default:
            return .slow
        }
    }
}
