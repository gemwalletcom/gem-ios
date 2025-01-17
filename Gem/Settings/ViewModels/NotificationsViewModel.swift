// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UserNotifications
import UIKit
import Store
import Localization
import NotificationService
import DeviceService
import BannerService
import Primitives
import Preferences

@Observable
@MainActor
final class NotificationsViewModel {
    private let deviceService: DeviceService
    private let preferences: Preferences
    private let pushNotificationService: PushNotificationEnablerService
    private let bannerService: BannerService

    var isEnabled: Bool

    init(
        deviceService: DeviceService,
        bannerService: BannerService,
        preferences: Preferences = .standard
    ) {
        self.deviceService = deviceService
        self.preferences = preferences
        self.pushNotificationService = PushNotificationEnablerService(preferences: preferences)
        self.isEnabled = preferences.isPushNotificationsEnabled
        self.bannerService = bannerService
    }
    
    var title: String {
        Localized.Settings.Notifications.title
    }
}

// MARK: - Business Logic

extension NotificationsViewModel {
    func enable(isEnabled: Bool) async throws {
        switch isEnabled {
        case true:
            self.isEnabled = try await requestPermissionsOrOpenSettings()
            if isEnabled {
                try bannerService.closeBanner(id: BannerEvent.enableNotifications.rawValue)
            }
        case false:
            preferences.isPushNotificationsEnabled = isEnabled
        }
        try await update()
    }
}

// MARK: - Private

extension NotificationsViewModel {
    private func update() async throws {
        try await deviceService.update()
    }

    private func requestPermissionsOrOpenSettings() async throws -> Bool {
        try await pushNotificationService.requestPermissionsOrOpenSettings()
    }
}
