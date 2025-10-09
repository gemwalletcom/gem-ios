// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import WidgetKit
import Preferences

internal struct WidgetPriceService {
    private let pricesService: any GemAPIPricesService
    private let assetsService: any GemAPIAssetsService
    private let preferences = SharedPreferences()
    
    init() {
        self.pricesService = GemAPIService()
        self.assetsService = GemAPIService()
    }
    
    internal func coins(_ widgetFamily: WidgetFamily) -> [AssetId] {
        switch widgetFamily {
        case .systemSmall:
            [AssetId(chain: .bitcoin, tokenId: nil)]
        default:
            [
                AssetId(chain: .bitcoin, tokenId: nil),
                AssetId(chain: .ethereum, tokenId: nil),
                AssetId(chain: .solana, tokenId: nil),
                AssetId(chain: .xrp, tokenId: nil),
                AssetId(chain: .smartChain, tokenId: nil),
            ]
        }
    }
    
    internal func fetchTopCoinPrices(widgetFamily: WidgetFamily = .systemMedium) async -> PriceWidgetEntry {
        let coins = coins(widgetFamily)
        let currency = preferences.currency
        
        do {
            let (assets, prices) = try await (
                assetsService.getAssets(assetIds: coins),
                pricesService.getPrices(currency: currency, assetIds: coins)
            )
            
            let coinPrices = assets.compactMap { asset -> CoinPrice? in
                guard let price = prices.first(where: { $0.assetId == asset.asset.id }) else { return nil }
                return CoinPrice(
                    assetId: asset.asset.id,
                    name: asset.asset.name,
                    symbol: asset.asset.symbol,
                    price: price.price,
                    priceChangePercentage24h: price.priceChangePercentage24h
                )
            }
            return PriceWidgetEntry(
                date: Date(),
                coinPrices: coinPrices,
                currency: currency,
                widgetFamily: widgetFamily
            )
        } catch {
            return PriceWidgetEntry.error(error: error.localizedDescription, widgetFamily: widgetFamily)
        }
    }
}
