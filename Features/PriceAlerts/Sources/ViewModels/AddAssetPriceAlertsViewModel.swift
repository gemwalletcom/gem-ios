// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PriceAlertService

public struct AddAssetPriceAlertsViewModel: Sendable {
    private let priceAlertService: PriceAlertService

    public init(priceAlertService: PriceAlertService) {
        self.priceAlertService = priceAlertService
    }

    public func onSelectAsset(_ asset: Asset)  {
        Task {
            try await priceAlertService.add(priceAlert: .default(for: asset.id.identifier))
            try await priceAlertService.enablePriceAlerts()
        }
    }
}
