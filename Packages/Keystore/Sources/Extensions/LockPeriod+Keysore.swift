// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension LockPeriod: CaseIterable {
    public static var allCases: [LockPeriod] = [.immediate, .oneMinute, .fiveMinutes, .fifteenMinutes, .oneHour, .sixHours]
}

extension LockPeriod: Identifiable {
    public var id: Self { self }
}
