// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct DebounceModifier<T: Hashable>: ViewModifier {
    @State private var debounceTask: Task<Void, Never>?
    @Binding var value: T

    let interval: Duration
    let action: (T) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, newValue in
                debounceTask?.cancel()
                debounceTask = Task {
                    try? await Task.sleep(for: interval)
                    // Check if the task is not cancelled before performing the action.
                    guard !Task.isCancelled else { return }
                    Task { @MainActor in
                        action(newValue)
                    }
                }
            }
    }
}

public extension View {
    func debounce<T: Hashable>(value: Binding<T>, interval: Duration, action: @escaping (T) -> Void) -> some View {
        modifier(DebounceModifier(value: value, interval: interval, action: action))
    }
}
