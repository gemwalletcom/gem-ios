// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit
import Preferences

public struct PushNotificationEnablerService: Sendable {

    private let preferences: Preferences

    public init(preferences: Preferences = .standard) {
        self.preferences = preferences
    }

    public func requestPermissions() async throws -> Bool {
        if !preferences.isPushNotificationsEnabled {
            preferences.isPushNotificationsEnabled = try await requestAuthorizationPermissions()
            return preferences.isPushNotificationsEnabled
        }
        return true
    }

    public func requestPermissionsOrOpenSettings() async throws -> Bool {
        let status = try await getNotificationSettingsStatus()
        switch status {
        case  .authorized, .ephemeral, .provisional:
            preferences.isPushNotificationsEnabled = true
            return preferences.isPushNotificationsEnabled
        case .notDetermined:
            return try await requestPermissions()
        case .denied:
            try await openSetting()
            return false
        @unknown default:
            return false
        }
    }
    
    public func getNotificationSettingsStatus() async throws -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        return await center.notificationSettings().authorizationStatus
    }
    
    public func openSetting() async throws {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            if await UIApplication.shared.canOpenURL(appSettings) {
                await UIApplication.shared.open(appSettings, completionHandler: .none)
            }
        }
    }

    private func requestAuthorizationPermissions() async throws -> Bool {
        let result = try await UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert])
        await UIApplication.shared.registerForRemoteNotifications()
        return result
    }
}
