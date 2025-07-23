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
        
        // Convert hourly funding rate to annual percentage
        // hourlyFunding is a decimal (e.g., 0.0000794237)
        // Annual percentage = hourly * 24 * 365 * 100
        let hourlyFunding = Double(funding) ?? 0
        let annualFunding = hourlyFunding * 24 * 365 * 100
        
        return Perpetual(
            id: "\(provider.rawValue)_\(symbol)",
            name: symbol,
            provider: provider,
            assetId: assetId,
            price: currentPrice,
            pricePercentChange24h: priceChange24h,
            openInterest: Double(openInterest) ?? 0,
            volume24h: Double(dayNtlVlm) ?? 0,
            funding: annualFunding,
            leverage: [UInt8(maxLeverage)]
        )
    }
}
