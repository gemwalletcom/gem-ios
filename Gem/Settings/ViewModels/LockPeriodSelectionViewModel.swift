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

    // TODO: - localize
    var title: String { "Require authentication" }
}

// MARK: - Model Extensions

extension LockOption {
    // TODO: - localize
    var title: String {
        switch self {
        case .immediate: "Immediately"
        case .oneMinute: "1 minute"
        case .fiveMinutes: "5 minutes"
        case .fifteenMinutes: "15 minutes"
        case .oneHour: "1 hour"
        case .sixHours: "6 hours"
        }
    }
}
