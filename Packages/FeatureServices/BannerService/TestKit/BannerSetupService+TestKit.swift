// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BannerService
import Store
import StoreTestKit
import NotificationService
import NotificationServiceTestKit
import Preferences
import PreferencesTestKit

public extension BannerSetupService {
    static func mock(
        store: BannerStore = .mock(),
        preferences: Preferences = .mock()
    ) -> Self {
        BannerSetupService(
            store: store,
            preferences: preferences
        )
    }
}
