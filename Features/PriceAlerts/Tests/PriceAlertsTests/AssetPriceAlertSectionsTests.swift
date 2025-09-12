// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
@testable import PriceAlerts
import Primitives
import PrimitivesTestKit

struct AssetPriceAlertSectionsTests {
    
    @Test
    func sections() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let alerts = [
            PriceAlertData.mock(priceAlert: .mock()),
            PriceAlertData.mock(priceAlert: .mock(price: 100.0, priceDirection: .up)),
            PriceAlertData.mock(priceAlert: .mock(price: 200.0, priceDirection: .down, lastNotifiedAt: today)),
            PriceAlertData.mock(priceAlert: .mock(price: 150.0, priceDirection: .up, lastNotifiedAt: yesterday))
        ]
        let sections = AssetPriceAlertSections(from: alerts)
        
        #expect(sections.auto != nil)
        #expect(sections.active.count == 1)
        #expect(sections.passed.count == 2)
        #expect(sections.passedGroupedByDate.count == 2)
        #expect(sections.passedHeaders.count == 2)
        #expect(sections.passedHeaders.first == Calendar.current.startOfDay(for: today))
        #expect(sections.passedHeaders.last == Calendar.current.startOfDay(for: yesterday))
    }
}

