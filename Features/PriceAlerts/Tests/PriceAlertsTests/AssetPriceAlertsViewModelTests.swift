// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PriceAlertService
import PriceAlertServiceTestKit
import Primitives
import PrimitivesTestKit

@testable import PriceAlerts

@MainActor
struct AssetPriceAlertsViewModelTests {
    @Test
    func alertsModelSorting() {
        let alert1 = PriceAlertData.mock(priceAlert: .mock(price: 100, priceDirection: .up))
        let alert2 = PriceAlertData.mock(priceAlert: .mock(price: 200, priceDirection: .down))
        let alert3 = PriceAlertData.mock(priceAlert: .mock(price: 200, priceDirection: .up))
        let autoAlert = PriceAlertData.mock(priceAlert: .mock(priceDirection: nil))
        
        let model = AssetPriceAlertsViewModel.mock()
        model.priceAlerts = [alert1, alert2, alert3, autoAlert]
        
        #expect(model.alertsModel.map { $0.data } == [alert3, alert2, alert1])
        #expect(model.autoAlertModel?.data == autoAlert)
    }
    
    @Test
    func emptyContentModel() {
        let model = AssetPriceAlertsViewModel.mock()
        
        #expect(model.emptyContentModel != nil)
        
        model.priceAlerts = [PriceAlertData.mock()]
        
        #expect(model.emptyContentModel == nil)
    }
}

extension AssetPriceAlertsViewModel {
    static func mock(
        priceAlertService: PriceAlertService = .mock(),
        walletId: WalletId = .mock(),
        asset: Asset = .mock()
    ) -> AssetPriceAlertsViewModel {
        AssetPriceAlertsViewModel(
            priceAlertService: priceAlertService,
            walletId: walletId,
            asset: asset
        )
    }
}
