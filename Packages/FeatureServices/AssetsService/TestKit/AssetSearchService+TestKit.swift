// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import Primitives
import Store
import StoreTestKit

extension AssetSearchService {
    public static func mock(
        assetsService: AssetsService = .mock(),
        searchStore: SearchStore = .mock()
    ) -> AssetSearchService {
        AssetSearchService(
            assetsService: assetsService,
            searchStore: searchStore
        )
    }
}
