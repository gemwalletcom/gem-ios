// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct DebounceModifier<T: Hashable & Sendable>: ViewModifier {
    @State private var debounceTask: Task<Void, Never>?

    let value: T
    let initial: Bool
    let interval: Duration?
    let action: @Sendable (T) async -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value, initial: initial) { _, newValue in
                debounceTask?.cancel()
                debounceTask = Task {
                    do {
                        if let interval {
                            try await Task.sleep(for: interval)
                        }
                        await action(newValue)
                    } catch {}
                }
            }
    }
}

public extension View {
    func debounce<T: Hashable & Sendable>(
        value: T,
        initial: Bool = false,
        interval: Duration? = .debounce,
        action: @Sendable @escaping (T) async -> Void
    ) -> some View {
        modifier(
            DebounceModifier(
                value: value,
                initial: initial,
                interval: interval,
                action: action
            )
        )
    }
}
