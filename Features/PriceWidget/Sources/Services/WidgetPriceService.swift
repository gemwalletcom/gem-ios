// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import PriceService
import GemstonePrimitives
import WidgetKit

public struct WidgetPriceService {
    private let priceService: PriceService
    
    public init() {
        let db = DB()
        let priceStore = PriceStore(db: db)
        let fiatRateStore = FiatRateStore(db: db)
        self.priceService = PriceService(
            priceStore: priceStore,
            fiatRateStore: fiatRateStore
        )
    }
    
    public func fetchTopCoinPrices(widgetFamily: WidgetFamily = .systemMedium) -> PriceWidgetEntry {
        // For now, always return placeholder data to test the widget
        return PriceWidgetEntry.placeholder(widgetFamily: widgetFamily)
        
        // TODO: Implement actual price fetching
        // The code below needs to be adjusted to work in widget extension context
        /*
        let topCoins = [
            AssetId(chain: .bitcoin, tokenId: nil),
            AssetId(chain: .ethereum, tokenId: nil),
            AssetId(chain: .solana, tokenId: nil),
            AssetId(chain: .xrp, tokenId: nil),
            AssetId(chain: .smartChain, tokenId: nil),
        ]
        
        do {
            let currency = getCurrency()
            let prices = try priceService.getPrices(for: topCoins)
            
            let coinPrices = prices.compactMap { price -> CoinPrice? in
                let chain = price.assetId.chain
                let name = chain.asset.name
                let symbol = chain.asset.symbol
                let imageURL = AssetImageFormatter().getURL(for: price.assetId)
                
                return CoinPrice(
                    assetId: price.assetId,
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
            // Return placeholder data on error
            return PriceWidgetEntry.placeholder(widgetFamily: widgetFamily)
        }
        */
    }
    
    public func getCurrency() -> String {
        UserDefaults(suiteName: "group.com.gemwallet.ios")?.string(forKey: "currency") ?? "USD"
    }
}
