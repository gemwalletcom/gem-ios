// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives

internal struct CoinPrice: Sendable, Identifiable {
    let assetId: AssetId
    let name: String
    let symbol: String
    let price: Double
    let priceChangePercentage24h: Double
    let image: Image?

    var id: AssetId { assetId }
}
