// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct LatencyMeasureService {
    public static func measure<T>(for asyncFunction: @escaping () async throws -> T) async throws -> (duration: Double, value: T) {
        let start = Date()
        let value = try await asyncFunction()
        let end = Date()
        let duration = end.timeIntervalSince(start) * 1000 // Convert to milliseconds
        return (duration: duration, value: value)
    }
}
