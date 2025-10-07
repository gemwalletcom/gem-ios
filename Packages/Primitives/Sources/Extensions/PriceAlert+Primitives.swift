// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension PriceAlert: Identifiable {
    public var id: String {
        if price == nil && pricePercentChange == nil && priceDirection == nil {
            return assetId.identifier
        }
        let price = price.map { String(format: "%g", $0) } ?? .none
        let pricePercentChange = pricePercentChange.map { String(format: "%g", $0) } ?? .none
        return [assetId.identifier, currency, price, pricePercentChange, priceDirection?.rawValue].compactMap {
            $0
        }
        .joined(separator: "_")
    }
}

public extension PriceAlert {
    static func `default`(for assetId: AssetId, currency: String) -> PriceAlert {
        PriceAlert(
            assetId: assetId,
            currency: currency,
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
    
    var shouldDisplay: Bool {
        switch type {
        case .auto: true
        case .price, .pricePercentChange: lastNotifiedAt == nil
        }
    }
}
