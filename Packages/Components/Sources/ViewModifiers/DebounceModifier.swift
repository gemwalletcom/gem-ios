// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct DebounceModifier<T: Hashable & Sendable>: ViewModifier {
    @State private var debounceTask: Task<Void, Never>?

    let value: T
    let interval: Duration?
    let action: @Sendable (T) async -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, newValue in
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
    func debounce<T: Hashable & Sendable>(value: T, interval: Duration?, action: @Sendable @escaping (T) async -> Void) -> some View {
        modifier(DebounceModifier(value: value, interval: interval, action: action))
    }
}
