// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PriceAlertService

struct AddAssetPriceAlertsViewModel {

    let priceAlertService: PriceAlertService

    func onSelectAsset(_ asset: Asset) {
        Task {
            try await priceAlertService.addPriceAlert(assetId: asset.id.identifier)
        }
    }
}
