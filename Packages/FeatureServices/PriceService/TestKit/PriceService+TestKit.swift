// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PriceService
import GemAPI
import GemAPITestKit
import Store
import StoreTestKit

public extension PriceService {
    static func mock(
        priceStore: PriceStore = .mock(),
        fiatRateStore: FiatRateStore = .mock()
    ) -> Self {
        PriceService(
            priceStore: priceStore,
            fiatRateStore: fiatRateStore
        )
    }
}
