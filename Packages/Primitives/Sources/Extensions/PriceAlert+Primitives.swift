// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension PriceAlert: Identifiable {
    public var id: String {
        [assetId, price?.description, pricePercentChange?.description, priceDirection?.rawValue].compactMap { $0 }.joined(separator: "_")
    }
}

public extension PriceAlert {
    static func `default`(for assetId: String) -> PriceAlert {
        PriceAlert(
            assetId: assetId,
            price: .none,
            pricePercentChange: .none,
            priceDirection: .none,
            lastNotifiedAt: .none
        )
    }
    
    var type: PriceAlertNotificationType {
        switch (priceDirection, price, pricePercentChange) {
        case (nil, nil, nil): .auto
        case (.some, .some, nil): .price
        case (.some, nil, .some): .pricePercentChange
        default: .auto
        }
    }
}
