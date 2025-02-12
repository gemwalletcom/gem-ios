// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension PriceAlert: Identifiable {
    public var id: String {
        [assetId, price?.description, pricePercentChange?.description].compactMap { $0 }.joined(separator: "_")
    }
}
