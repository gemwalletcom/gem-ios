// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public actor PeriodicRunner: Sendable {
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
            await loop(every: duration, action: action)
        }
    }

    private func loop(
        every duration: Duration,
        action: @Sendable @escaping () async throws -> Void
    ) async {
        do {
            try await Task.sleep(for: duration)
            try await action()
        } catch {
            NSLog("PeriodicRunner action error: \(error)")
            return
        }

        if task?.isCancelled != true {
            await loop(every: duration, action: action)
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
