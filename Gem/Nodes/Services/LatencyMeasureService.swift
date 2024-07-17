// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style

struct LatencyMeasureService {
    enum Latency {
        case fast(Double)
        case normal(Double)
        case slow(Double)

        init(latency: Double) {
            switch latency {
            case ..<420:
                self = .fast(latency)
            case ..<1024:
                self = .normal(latency)
            default:
                self = .slow(latency)
            }
        }

        var colorEmoji: String {
            switch self {
            case .fast: return Emoji.greenCircle
            case .normal: return Emoji.orangeCircle
            case .slow: return Emoji.redCircle
            }
        }

        var value: Int {
            switch self {
            case .fast(let double), .normal(let double), .slow(let double):
                return Int(double)
            }
        }
    }

    static func measure<T>(for asyncFunction: @escaping () async throws -> T) async throws -> (latency: Latency, value: T) {
        let start = Date()
        let value = try await asyncFunction()
        let end = Date()
        let duration = end.timeIntervalSince(start) * 1000 // Convert to milliseconds
        let latency = Latency(latency: duration)
        return (latency: latency, value: value)
    }
}
