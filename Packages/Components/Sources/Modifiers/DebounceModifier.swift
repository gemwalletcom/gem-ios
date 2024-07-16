// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct DebouncingModifier<T: Hashable>: ViewModifier {
    @State private var debounceTask: Task<Void, Never>?
    @Binding var value: T

    let debounceInterval: Duration
    let action: (T) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, newValue in
                debounceTask?.cancel()
                debounceTask = Task {
                    try? await Task.sleep(for: debounceInterval)
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
    func debounce<T: Hashable>(value: Binding<T>, debounceInterval: Duration, action: @escaping (T) -> Void) -> some View {
        modifier(DebouncingModifier(value: value, debounceInterval: debounceInterval, action: action))
    }
}
