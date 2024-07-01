// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct LatencyMeasureService {
    enum Latency {
        case fast(Double)
        case normal(Double)
        case slow(Double)

        init(latency: Double) {
            switch latency {
            case ..<420:
                self = .fast(latency)
            case 420..<840:
                self = .normal(latency)
            default:
                self = .slow(latency)
            }
        }

        private var colorEmoji: String {
            switch self {
            case .fast: return "🟢"
            case .normal: return "🟠"
            case .slow: return "🔴"
            }
        }

        var value: Int {
            let value: Double
            switch self {
            case .fast(let double):
                value = double
            case .normal(let double):
                value = double
            case .slow(let double):
                value = double
            }
            return Int(value)
        }

        var formattedValue: String {
            let ms = Localized.Common.ms
            return "\(value) \(ms) \(colorEmoji)"
        }
    }

    static func measure<T>(for asyncFunction: @escaping () async throws -> T?) async throws -> (latency: Latency, value: T?) {
        let start = Date()
        let value = try await asyncFunction()
        let end = Date()
        let duration = end.timeIntervalSince(start) * 1000 // Convert to milliseconds
        let latency = Latency(latency: duration)
        return (latency: latency, value: value)
    }
}
