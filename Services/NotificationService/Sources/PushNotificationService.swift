// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit
import Store

public struct PushNotificationEnablerService: Sendable {

    private let preferences: Preferences

    public init(
        preferences: Preferences
    ) {
        self.preferences = preferences
    }

    public func requestPermissions() async throws -> Bool {
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
