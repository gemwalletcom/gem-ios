// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension HypercoreAssetMetadata {
    public func mapToPerpetual(
        symbol: String,
        maxLeverage: Int
    ) -> Perpetual? {
        let provider = PerpetualProvider.hypercore
        guard let assetId = mapHypercoreCoinToAssetId(symbol) else { return nil }
        
        let prevPrice = Double(prevDayPx) ?? 0
        let currentPrice = Double(midPx ?? markPx) ?? 0
        let priceChange24h = prevPrice > 0 ? ((currentPrice - prevPrice) / prevPrice) * 100 : 0
        
        return Perpetual(
            id: "\(provider.rawValue)_\(symbol)",
            name: symbol,
            provider: provider,
            asset_id: assetId,
            price: currentPrice,
            price_percent_change_24h: priceChange24h,
            open_interest: Double(openInterest) ?? 0,
            volume_24h: Double(dayNtlVlm) ?? 0,
            leverage: [UInt8(maxLeverage)]
        )
    }
}
