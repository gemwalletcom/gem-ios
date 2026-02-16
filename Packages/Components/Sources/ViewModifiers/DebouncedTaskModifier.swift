// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public extension View {
    func debouncedTask<T: DebouncableTrigger>(
        id trigger: T?,
        interval: Duration = .Debounce.normal,
        action: @Sendable @escaping () async -> Void
    ) -> some View {
        task(id: trigger) {
            guard let trigger else { return }
            if !trigger.isImmediate {
                try? await Task.sleep(for: interval)
                guard !Task.isCancelled else { return }
            }
            await action()
        }
    }
}
