// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public typealias Interval = TimeInterval

public extension Interval {
    /// 30s
    static let seconds30: Interval = 30
    /// 60s
    static let minute1: Interval = 60
    /// 300s
    static let minutes5: Interval = 300

    struct AnimationDuration {
        /// 0.15s
        public static let fast: Interval = 0.15
        /// 0.2s
        public static let normal: Interval = 0.2
        /// 0.5s
        public static let slow: Interval = 0.5
        /// 1.8s
        public static let verySlow: Interval = 1.8
    }
}

public extension Duration {
    struct Debounce {
        /// 150ms
        public static let fast: Duration = .milliseconds(150)
        /// 250ms
        public static let normal: Duration = .milliseconds(250)
        /// 1s
        public static let slow: Duration = .seconds(1)
    }
}
