// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import NotificationService
import Preferences
import PreferencesTestKit

public extension PushNotificationEnablerService {
    static func mock(preferences: Preferences = .mock()) -> Self {
        PushNotificationEnablerService(
            preferences: preferences
        )
    }
}
