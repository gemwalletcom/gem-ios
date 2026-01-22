// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension AssetMarket {
    public static func mock(
        marketCap: Double? = 1_000_000,
        marketCapFdv: Double? = 2_000_000,
        marketCapRank: Int32? = 1,
        totalVolume: Double? = 500_000,
        circulatingSupply: Double? = 100_000,
        totalSupply: Double? = 200_000,
        maxSupply: Double? = 300_000,
        allTimeHigh: Double? = 100,
        allTimeHighDate: Date? = .now,
        allTimeHighChangePercentage: Double? = -10,
        allTimeLow: Double? = 1,
        allTimeLowDate: Date? = .now,
        allTimeLowChangePercentage: Double? = 100
    ) -> AssetMarket {
        AssetMarket(
            marketCap: marketCap,
            marketCapFdv: marketCapFdv,
            marketCapRank: marketCapRank,
            totalVolume: totalVolume,
            circulatingSupply: circulatingSupply,
            totalSupply: totalSupply,
            maxSupply: maxSupply,
            allTimeHigh: allTimeHigh,
            allTimeHighDate: allTimeHighDate,
            allTimeHighChangePercentage: allTimeHighChangePercentage,
            allTimeLow: allTimeLow,
            allTimeLowDate: allTimeLowDate,
            allTimeLowChangePercentage: allTimeLowChangePercentage
        )
    }
}
