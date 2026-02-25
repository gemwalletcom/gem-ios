// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PriceAlertServiceTestKit
import Primitives
import PrimitivesTestKit

@testable import PriceAlerts

struct PriceAlertsViewModelTests {
    @Test @MainActor
    func testSections() {
        let model = PriceAlertsSceneViewModel(priceAlertService: .mock())
        
        let autoAlert = PriceAlertData.mock()
        let manualAlert = PriceAlertData.mock(priceAlert: .mock(price: 5, priceDirection: .down))
        let manualSolAlert = PriceAlertData.mock(asset: .mock(name: "Solana"), priceAlert: .mock(price: 5, priceDirection: .down))
        let notifiedAlert = PriceAlertData.mock(priceAlert: .mock(price: 5, priceDirection: .down, lastNotifiedAt: Date()))
        
        let sections = model.sections(for: [autoAlert, manualAlert, manualSolAlert, notifiedAlert])
        
        #expect(sections.autoAlerts == [autoAlert])
        #expect(sections.manualAlerts[manualAlert.asset] == [manualAlert])
        #expect(sections.manualAlerts[manualSolAlert.asset] == [manualSolAlert])
        
        #expect(sections.manualAlerts.values.flatMap { $0 }.contains(where: { $0 == notifiedAlert }) == false)
    }
}
