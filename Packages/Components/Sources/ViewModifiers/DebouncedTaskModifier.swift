// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct DebouncedTaskModifier<T: DebouncableTrigger>: ViewModifier {
    let trigger: T
    let interval: Duration
    let action: @Sendable () async -> Void

    func body(content: Content) -> some View {
        content
            .task(id: trigger) {
                if !trigger.isImmediate {
                    try? await Task.sleep(for: interval)
                    guard !Task.isCancelled else { return }
                }
                await action()
            }
    }
}

public extension View {
    func debouncedTask<T: DebouncableTrigger>(
        id trigger: T,
        interval: Duration = .Debounce.normal,
        action: @Sendable @escaping () async -> Void
    ) -> some View {
        modifier(
            DebouncedTaskModifier(
                trigger: trigger,
                interval: interval,
                action: action
            )
        )
    }
}
