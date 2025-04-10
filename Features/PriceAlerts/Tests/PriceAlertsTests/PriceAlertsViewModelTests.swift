// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PriceAlertServiceTestKit
import Primitives
import PrimitivesTestKit

@testable import PriceAlerts

struct PriceAlertsViewModelTests {
    @Test
    func sectionsTest() {
        let model = PriceAlertsViewModel(priceAlertService: .mock())
        
        let autoAlert = PriceAlertData.mock()
        let manualAlert = PriceAlertData.mock(priceAlert: .mock(price: 5, priceDirection: .down))
        let manualSolAlert = PriceAlertData.mock(asset: .mock(name: "Solana"), priceAlert: .mock(price: 5, priceDirection: .down))
        let notifiedAlert = PriceAlertData.mock(priceAlert: .mock(price: 5, priceDirection: .down, lastNotifiedAt: Date()))
        
        let sections = model.sections(for: [autoAlert, manualAlert, manualSolAlert, notifiedAlert])
        
        #expect(sections.autoAlerts.first == autoAlert)
        #expect(sections.manualAlerts.first?.first == manualAlert)
        #expect(sections.manualAlerts.last?.first == manualSolAlert)
        #expect(!sections.manualAlerts.flatMap { $0 }.contains(where: { $0 == notifiedAlert }))
    }
}
