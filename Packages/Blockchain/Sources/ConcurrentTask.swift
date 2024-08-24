// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ConcurrentTask {
    public static func results<T: Sendable, R: Sendable>(
        for items: [T],
        _ task: @Sendable @escaping (T) async throws -> R
    ) async -> [R] {
        await withTaskGroup(of: R?.self) { group in
            for item in items {
                group.addTask {
                    try? await task(item)
                }
            }

            var results: [R] = []
            for await result in group {
                if let result {
                    results.append(result)
                }
            }
            return results
        }
    }
}
