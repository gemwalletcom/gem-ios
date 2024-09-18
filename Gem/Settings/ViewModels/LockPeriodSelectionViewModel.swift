// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store

struct LockPeriodSelectionViewModel {
    private let preferences: Preferences

    let allOptions: [LockOption] = LockOption.allCases
    var selectedOption: LockOption {
        didSet {
            preferences.authenticationLockOption = selectedOption.id
        }
    }

    init(preferences: Preferences = Preferences.main) {
        self.preferences = preferences
        let lockOption = LockOption(rawValue: preferences.authenticationLockOption) ?? .immediate
        self.selectedOption = lockOption
    }

    var title: String { Localized.Lock.requireAuthentication }
}

// MARK: - Model Extensions

extension LockOption {
    var title: String {
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
