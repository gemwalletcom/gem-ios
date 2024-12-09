// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct DebounceModifier<T: Hashable>: ViewModifier {
    @State private var debounceTask: Task<Void, Never>?
    @Binding var value: T

    let interval: Duration?
    let action: (T) async -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { _, newValue in
                debounceTask?.cancel()
                debounceTask = Task {
                    if let interval {
                        do {
                            try await Task.sleep(for: interval)
                        } catch {
                            return
                        }
                    }
                    guard !Task.isCancelled else { return }
                    await action(newValue)
                }
            }
    }
}

public extension View {
    func debounce<T: Hashable>(value: Binding<T>, interval: Duration?, action: @escaping (T) async -> Void) -> some View {
        modifier(DebounceModifier(value: value, interval: interval, action: action))
    }
}
