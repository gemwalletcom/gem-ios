// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import GemstonePrimitives
import WidgetKit

public struct WidgetPriceService {
    private let pricesService: GemAPIPricesService
    
    public init() {
        self.pricesService = GemAPIService()
    }
    
    public func fetchTopCoinPrices(widgetFamily: WidgetFamily = .systemMedium) async -> PriceWidgetEntry {
        let coins = [
            AssetId(chain: .bitcoin, tokenId: nil),
            AssetId(chain: .ethereum, tokenId: nil),
            AssetId(chain: .solana, tokenId: nil),
            AssetId(chain: .xrp, tokenId: nil),
            AssetId(chain: .smartChain, tokenId: nil),
        ]
        
        NSLog("coins \(coins)")
        
        do {
            let prices = try await pricesService.getPrices(currency: "USD", assetIds: coins)
            
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
                widgetFamily: widgetFamily
            )
        } catch {
            NSLog("Widget price fetch error: \(error)")
            NSLog("Error type: \(type(of: error))")
            NSLog("Error description: \(error.localizedDescription)")
            return PriceWidgetEntry.error(error: error.localizedDescription, widgetFamily: widgetFamily)
        }
    }
}
