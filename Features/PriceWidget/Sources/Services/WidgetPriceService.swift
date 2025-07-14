// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import PriceService

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
    
    public func fetchTopCoinPrices() async -> [CoinPrice] {
        let topCoins = [
            AssetId(chain: .bitcoin, tokenId: nil),
            AssetId(chain: .ethereum, tokenId: nil),
            AssetId(chain: .solana, tokenId: nil),
            AssetId(chain: .xrp, tokenId: nil),
            AssetId(chain: .smartChain, tokenId: nil),
        ]
        
        do {
            let prices = try priceService.getPrices(for: topCoins)
            
            return prices.compactMap { price -> CoinPrice? in
                let chain = price.assetId.chain
                let name = chain.asset.name
                let symbol = chain.asset.symbol
                
                return CoinPrice(
                    assetId: price.assetId,
                    name: name,
                    symbol: symbol,
                    price: price.price,
                    priceChangePercentage24h: price.priceChangePercentage24h,
                    imageURL: .none //chain.assetImage
                )
            }
        } catch {
            // Return placeholder data on error
            return CoinPrice.placeholders()
        }
    }
    
    public func getCurrency() -> String {
        UserDefaults(suiteName: "group.com.gemwallet.ios")?.string(forKey: "currency") ?? "USD"
    }
}
