// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension HypercoreAssetMetadata {
    public func mapToPerpetual(
        symbol: String,
        maxLeverage: Int,
        index: Int,
    ) -> Perpetual? {
        let provider = PerpetualProvider.hypercore
        let assetId = mapHypercoreCoinToAssetId(symbol)
        
        let prevPrice = Double(prevDayPx) ?? 0
        let currentPrice = Double(midPx ?? markPx) ?? 0
        let priceChange24h = prevPrice > 0 ? ((currentPrice - prevPrice) / prevPrice) * 100 : 0
        let fundingRate = (Double(funding) ?? 0) * 100
        
        let openInterestInCoins = Double(openInterest) ?? 0
        let openInterestInUSD = openInterestInCoins * currentPrice
        
        let volume24h = Double(dayNtlVlm) ?? 0
         
        return Perpetual(
            id: "\(provider.rawValue)_\(symbol)",
            name: symbol,
            provider: provider,
            assetId: assetId,
            identifier: index.description,
            price: currentPrice,
            pricePercentChange24h: priceChange24h,
            openInterest: openInterestInUSD,
            volume24h: volume24h,
            funding: fundingRate,
            leverage: [UInt8(maxLeverage)]
        )
    }
}
