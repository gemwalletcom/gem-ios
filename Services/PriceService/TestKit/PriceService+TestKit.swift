// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceService
import GemAPI
import GemAPITestKit
import Store
import StoreTestKit

public extension PriceService {
    static func mock(
        apiService: any GemAPIPriceService = GemAPIPriceServiceMock(),
        priceStore: PriceStore = .mock()
    ) -> Self {
        PriceService(
            apiService: apiService,
            priceStore: priceStore
        )
    }
}
