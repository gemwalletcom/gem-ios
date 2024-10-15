// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit
import Store

struct PushNotificationEnablerService {

    private let preferences: Preferences

    init(
        preferences: Preferences
    ) {
        self.preferences = preferences
    }

    func requestPermissions() async throws -> Bool {
        if !preferences.isPushNotificationsEnabled {
            preferences.isPushNotificationsEnabled = try await requestAuthorizationPermissions()
            return preferences.isPushNotificationsEnabled
        }
        return true
    }

    private func requestAuthorizationPermissions() async throws -> Bool {
        let result = try await UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert])
        await UIApplication.shared.registerForRemoteNotifications()
        return result
    }
}
