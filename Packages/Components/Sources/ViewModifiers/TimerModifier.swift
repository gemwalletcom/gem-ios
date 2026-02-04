// Copyright (c). Gem Wallet. All rights reserved.

import Combine
import SwiftUI

private struct TimerModifier: ViewModifier {
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    private let action: @Sendable () async -> Void

    init(every interval: TimeInterval, tolerance: TimeInterval, action: @Sendable @escaping () async -> Void) {
        self.timer = Timer.publish(every: interval, tolerance: tolerance, on: .main, in: .common).autoconnect()
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .onReceive(timer) { _ in
                Task {
                    await action()
                }
            }
    }
}

public extension View {
    func onTimer(every interval: TimeInterval, tolerance: TimeInterval = 1, action: @Sendable @escaping () async -> Void) -> some View {
        modifier(TimerModifier(every: interval, tolerance: tolerance, action: action))
    }
}
