// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UserNotifications
import UIKit
import Store
import Localization

struct NotificationsViewModel {
    
    let deviceService: DeviceService
    let subscriptionService: SubscriptionService
    let preferences: Preferences
    let pushNotificationService: PushNotificationEnablerService

    init(
        deviceService: DeviceService,
        subscriptionService: SubscriptionService,
        preferences: Preferences
    ) {
        self.deviceService = deviceService
        self.subscriptionService = subscriptionService
        self.preferences = preferences
        self.pushNotificationService = PushNotificationEnablerService(preferences: preferences)
    }

    var isPushNotificationsEnabled: Bool {
        preferences.isPushNotificationsEnabled
    }
    
    var title: String {
        return Localized.Settings.Notifications.title
    }
    
    func update() async throws {
        try await deviceService.update()
    }
    
    func requestPermissions() async throws -> Bool {
        try await pushNotificationService.requestPermissions()
    }
}
