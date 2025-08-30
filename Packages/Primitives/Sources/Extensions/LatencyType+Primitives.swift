// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension LatencyType {
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

public extension Latency {
    var type: LatencyType { latency_type }
    
    static func from(duration: Double) -> Latency {
        Latency(
            latency_type: LatencyType.from(duration: duration),
            value: duration
        )
    }
}