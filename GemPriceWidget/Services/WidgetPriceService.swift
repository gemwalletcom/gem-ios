// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import GemstonePrimitives
import WidgetKit
import Preferences

internal struct WidgetPriceService {
    private let pricesService: any GemAPIPricesService
    private let preferences = SharedPreferences()
    
    init() {
        self.pricesService = GemAPIService()
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
            let prices = try await pricesService.getPrices(currency: currency, assetIds: coins)
            
            let coinPrices = coins.enumerated().compactMap { index, assetId -> CoinPrice? in
                guard index < prices.count else { return nil }
                let price = prices[index]
                let chain = assetId.chain
                let name = chain.asset.name
                let symbol = chain.asset.symbol
                let imageURL = AssetImageFormatter().getURL(for: assetId)
                
                return CoinPrice(
                    assetId: assetId,
                    name: name,
                    symbol: symbol,
                    price: price.price,
                    priceChangePercentage24h: price.priceChangePercentage24h,
                    imageURL: imageURL
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
