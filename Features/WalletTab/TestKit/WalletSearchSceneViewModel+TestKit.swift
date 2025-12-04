// Copyright (c). Gem Wallet. All rights reserved.

import WalletTab
import Primitives
import PrimitivesTestKit
import AssetsService
import AssetsServiceTestKit
import ActivityService
import ActivityServiceTestKit
import Preferences
import PreferencesTestKit

public extension WalletSearchSceneViewModel {
    @MainActor
    static func mock(
        wallet: Wallet = .mock(),
        searchService: AssetSearchService = .mock(),
        activityService: ActivityService = .mock(),
        preferences: Preferences = .mock()
    ) -> WalletSearchSceneViewModel {
        WalletSearchSceneViewModel(
            wallet: wallet,
            searchService: searchService,
            activityService: activityService,
            preferences: preferences,
            onDismissSearch: {},
            onSelectAssetAction: { _ in },
            onAddToken: {}
        )
    }
}
