// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences
import Localization

public struct AssetPriceDetailsViewModel {
    private let priceData: PriceData
    private let currency: String

    public init(
        priceData: PriceData,
        currency: String = Preferences.standard.currency
    ) {
        self.priceData = priceData
        self.currency = currency
    }

    var title: String { Localized.Markets.title }

    var market: AssetMarketViewModel {
        AssetMarketViewModel(
            market: priceData.market!,
            assetSymbol: priceData.asset.symbol,
            currency: currency
        )
    }

    var marketValues: [MarketValueViewModel] {
        [market.marketCap, market.tradingVolume, market.fdv].withValues()
    }

    var supplyValues: [MarketValueViewModel] {
        [market.circulatingSupply, market.totalSupply, market.maxSupply].withValues()
    }

    var allTimeValues: [MarketValueViewModel] {
        [market.allTimeHigh, market.allTimeLow].withValues()
    }
}
