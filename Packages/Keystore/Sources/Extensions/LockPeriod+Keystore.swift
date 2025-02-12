// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension LockPeriod: CaseIterable {
    public static let allCases: [LockPeriod] = [.immediate, .oneMinute, .fiveMinutes, .fifteenMinutes, .oneHour, .sixHours]
}

extension LockPeriod: Identifiable {
    public var id: Self { self }
}

extension LockPeriod {
    public var value: Int {
        switch self {
        case .immediate: 0
        case .oneMinute: 60
        case .fiveMinutes: 300
        case .fifteenMinutes: 900
        case .oneHour: 3600
        case .sixHours: 21600
        }
    }
}
