// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Localization

extension LockPeriod {
    public var title: String {
        switch self {
        case .immediate: Localized.Lock.immediately
        case .oneMinute: Localized.Lock.oneMinute
        case .fiveMinutes: Localized.Lock.fiveMinutes
        case .fifteenMinutes: Localized.Lock.fifteenMinutes
        case .oneHour: Localized.Lock.oneHour
        case .sixHours: Localized.Lock.sixHours
        }
    }
}
