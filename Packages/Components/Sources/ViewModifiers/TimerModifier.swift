// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

private struct TimerModifier: ViewModifier {
    let interval: TimeInterval
    let action: @Sendable () async -> Void

    func body(content: Content) -> some View {
        content
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(interval))
                    guard !Task.isCancelled else { break }
                    await action()
                }
            }
    }
}

public extension View {
    func onTimer(every interval: TimeInterval, action: @Sendable @escaping () async -> Void) -> some View {
        modifier(TimerModifier(interval: interval, action: action))
    }
}
