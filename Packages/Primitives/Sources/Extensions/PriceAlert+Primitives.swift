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
    
    enum AlertType {
        case auto
        case price
        case pricePercent
    }
    
    var type: AlertType {
        switch (priceDirection, price, pricePercentChange) {
        case (nil, _, _): .auto
        case (_, .some, _): .price
        case (_, _, .some): .pricePercent
        default: .auto
        }
    }
}
