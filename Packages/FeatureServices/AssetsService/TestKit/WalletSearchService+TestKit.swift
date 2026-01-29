// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import Store
import StoreTestKit
import Preferences
import PreferencesTestKit

extension WalletSearchService {
    public static func mock(
        assetsService: AssetsService = .mock(),
        searchStore: SearchStore = .mock(),
        perpetualStore: PerpetualStore = .mock(),
        priceStore: PriceStore = .mock(),
        preferences: Preferences = .mock()
    ) -> WalletSearchService {
        WalletSearchService(
            assetsService: assetsService,
            searchStore: searchStore,
            perpetualStore: perpetualStore,
            priceStore: priceStore,
            preferences: preferences
        )
    }
}
