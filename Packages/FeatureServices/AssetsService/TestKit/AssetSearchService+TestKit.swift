// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AssetsService
import Primitives

extension AssetSearchService {
    public static func mock(
        assetsService: AssetsService = .mock()
    ) -> AssetSearchService {
        AssetSearchService(assetsService: assetsService)
    }
}
