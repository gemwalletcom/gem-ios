// Copyright (c). Gem Wallet. All rights reserved.

import WidgetKit
import SwiftUI
import Primitives
import PriceService
import Store
import Preferences
import GemstonePrimitives

public struct PriceWidgetProvider: TimelineProvider {
    public typealias Entry = PriceWidgetEntry
    
    private let priceService: PriceService
    private let topCoins: [AssetId]
    private let imageFormatter = AssetImageFormatter()
    
    public init() {
        let db = DB()
        self.priceService = PriceService(
            priceStore: PriceStore(db: db),
            fiatRateStore: FiatRateStore(db: db)
        )
        
        // Define top 5 coins
        self.topCoins = [
            AssetId(chain: .bitcoin, tokenId: nil),
            AssetId(chain: .ethereum, tokenId: nil),
            AssetId(chain: .solana, tokenId: nil),
            AssetId(chain: .xrp, tokenId: nil),
            AssetId(chain: .smartChain, tokenId: nil),
        ]
    }
    
    public func placeholder(in context: Context) -> PriceWidgetEntry {
        PriceWidgetEntry.placeholder()
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (PriceWidgetEntry) -> Void) {
        if context.isPreview {
            completion(PriceWidgetEntry.placeholder())
        } else {
            let entry = fetchPrices()
            completion(entry)
        }
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<PriceWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = fetchPrices()
        
        NSLog("entry \(entry)")
        
        // Update every 15 minutes
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    private func fetchPrices() -> PriceWidgetEntry {
        do {
            // Get current currency from preferences
            let preferences = Preferences()
            let currency = preferences.currency
            
            // Fetch prices
            let prices = try priceService.getPrices(for: topCoins)
            
            // Convert to CoinPrice
            let coinPrices = prices.compactMap { price -> CoinPrice? in
                let chain = price.assetId.chain
                let name = chain.asset.name
                let symbol = chain.asset.symbol
                let imageURL = imageFormatter.getURL(for: price.assetId)
                
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
                currency: currency
            )
        } catch {
            // Return placeholder data on error
            return PriceWidgetEntry.placeholder()
        }
    }
}
