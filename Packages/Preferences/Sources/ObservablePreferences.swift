// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

@Observable
public final class ObservablePreferences: Sendable {
    public static let `default` = ObservablePreferences()

    public let preferences: Preferences

    private init(preferences: Preferences = .standard) {
        self.preferences = preferences
    }

    @ObservationIgnored
    public var isHideBalanceEnabled: Bool {
        get {
            access(keyPath: \.isHideBalanceEnabled)
            return preferences.isHideBalanceEnabled
        }
        set {
            withMutation(keyPath: \.isHideBalanceEnabled) {
                preferences.isHideBalanceEnabled = newValue
            }
        }
    }

    @ObservationIgnored
    public var isPriceAlertsEnabled: Bool {
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

// MARK: - EnvironmentValues

extension EnvironmentValues {
    @Entry public var observablePreferences: ObservablePreferences = .default
}



