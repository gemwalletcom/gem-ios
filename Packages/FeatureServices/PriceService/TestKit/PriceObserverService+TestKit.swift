// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceService
import Preferences
import PreferencesTestKit

public extension PriceObserverService {
    static func mock(
        priceService: PriceService = .mock(),
        preferences: Preferences = .mock()
    ) -> PriceObserverService {
        PriceObserverService(
            priceService: priceService,
            preferences: preferences
        )
    }
}
