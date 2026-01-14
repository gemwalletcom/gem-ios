// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import Store
import StoreTestKit

extension WalletSearchService {
    public static func mock(
        assetsService: AssetsService = .mock(),
        searchStore: SearchStore = .mock(),
        perpetualStore: PerpetualStore = .mock()
    ) -> WalletSearchService {
        WalletSearchService(
            assetsService: assetsService,
            searchStore: searchStore,
            perpetualStore: perpetualStore
        )
    }
}
