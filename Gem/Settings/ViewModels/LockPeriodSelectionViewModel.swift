// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Localization

@Observable
class LockPeriodSelectionViewModel {
    private let service: any BiometryAuthenticatable

    var selectedPeriod: LockPeriod

    init(service: any BiometryAuthenticatable) {
        self.service = service
        self.selectedPeriod = service.lockPeriod
    }

    var title: String { Localized.Lock.requireAuthentication }

    var allPeriods: [LockPeriod] {
        LockPeriod.allCases
    }

    func update(period: LockPeriod) {
        do {
            try service.update(period: period)
            selectedPeriod = period
        } catch {
            selectedPeriod = service.lockPeriod
        }
    }
}

// MARK: - Models extension

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
