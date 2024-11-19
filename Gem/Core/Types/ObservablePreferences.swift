// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store

@Observable
final class ObservablePreferences: Sendable {
    let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    @ObservationIgnored
    var isBalancePrivacyEnabled: Bool {
        get {
            access(keyPath: \.isBalancePrivacyEnabled)
            return preferences.isBalancePrivacyEnabled
        }
        set {
            withMutation(keyPath: \.isBalancePrivacyEnabled) {
                preferences.isBalancePrivacyEnabled = newValue
            }
        }
    }

    @ObservationIgnored
    var isPriceAlertsEnabled: Bool {
        get {
            access(keyPath: \.isPriceAlertsEnabled)
            return preferences.isPriceAlertsEnabled
        }
        set {
            withMutation(keyPath: \.isPriceAlertsEnabled) {
                preferences.isPriceAlertsEnabled = newValue
            }
        }
    }
}

extension ObservablePreferences {
    static let `default` = ObservablePreferences(preferences: .main)
}

extension EnvironmentValues {
    @Entry var observablePreferences: ObservablePreferences = .default
}



