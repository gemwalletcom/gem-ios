// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public actor Runner: Sendable {
    private var task: Task<Void, Never>?

    public func start(
        every duration: Duration,
        runImmediately: Bool,
        action: @Sendable @escaping () async throws -> Void
    ) {
        cancel()
        task = Task {
            if runImmediately {
                await perform(action: action)
            }

            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: duration)
                    try await action()
                } catch {
                    NSLog("PeriodicRunner action error: \(error)")
                }
            }
        }
    }

    private func perform(action: @Sendable @escaping () async throws -> Void) async {
        do {
            try await action()
        } catch {
            NSLog("PeriodicRunner action error: \(error)")
        }
    }

    public func cancel() {
        task?.cancel()
        task = nil
    }
}
