// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore

@Observable
class LockPeriodSelectionViewModel {
    private let service: any BiometryAuthenticatable

    var selectedPeriod: LockPeriod

    init(service: any BiometryAuthenticatable) {
        self.service = service
        self.selectedPeriod = service.lockPeriod ?? .immediate
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
            selectedPeriod = service.lockPeriod ?? .immediate
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
