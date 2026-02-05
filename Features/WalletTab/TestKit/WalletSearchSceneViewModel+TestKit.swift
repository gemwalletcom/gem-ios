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
import WalletsService
import WalletsServiceTestKit
import PerpetualService
import PerpetualServiceTestKit

public extension WalletSearchSceneViewModel {
    @MainActor
    static func mock(
        wallet: Wallet = .mock(),
        searchService: WalletSearchService = .mock(),
        activityService: ActivityService = .mock(),
        walletsService: WalletsService = .mock(),
        perpetualService: PerpetualService = .mock(),
        preferences: ObservablePreferences = .mock()
    ) -> WalletSearchSceneViewModel {
        WalletSearchSceneViewModel(
            wallet: wallet,
            searchService: searchService,
            activityService: activityService,
            walletsService: walletsService,
            perpetualService: perpetualService,
            preferences: preferences,
            onDismissSearch: {},
            onSelectAssetAction: { _ in },
            onAddToken: {}
        )
    }
}
