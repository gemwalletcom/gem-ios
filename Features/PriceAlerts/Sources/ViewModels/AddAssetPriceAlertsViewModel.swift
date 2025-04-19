// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PriceAlertService
import Preferences

public struct AddAssetPriceAlertsViewModel: Sendable {
    private let priceAlertService: PriceAlertService
    private let preferences = Preferences.standard
    
    public init(priceAlertService: PriceAlertService) {
        self.priceAlertService = priceAlertService
    }

    public func onSelectAsset(_ asset: Asset)  {
        Task {
            try await priceAlertService
                .add(priceAlert: .default(for: asset.id, currency: preferences.currency))
            try await priceAlertService.enablePriceAlerts()
        }
    }
}
