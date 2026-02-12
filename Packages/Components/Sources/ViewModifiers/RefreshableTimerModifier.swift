// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

private struct RefreshableTimerModifier: ViewModifier {
    let interval: TimeInterval
    let action: @Sendable () async -> Void

    @State private var trigger = 0

    func body(content: Content) -> some View {
        content
            .refreshable {
                trigger += 1
                await action()
            }
            .task(id: trigger) {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(interval))
                    guard !Task.isCancelled else { break }
                    await action()
                }
            }
    }
}

public extension View {
    func refreshableTimer(every interval: TimeInterval, action: @Sendable @escaping () async -> Void) -> some View {
        modifier(RefreshableTimerModifier(interval: interval, action: action))
    }
}
