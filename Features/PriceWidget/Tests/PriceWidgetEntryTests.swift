// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import PriceWidget
import PriceWidgetTestKit
import Primitives

struct PriceWidgetEntryTests {
    
    @Test
    func empty() {
        let entry = PriceWidgetEntry.empty()
        
        #expect(entry.coinPrices.isEmpty)
        #expect(entry.currency == "USD")
    }
    
    @Test
    func placeholder() {
        let entry = PriceWidgetEntry.placeholder()
        
        #expect(entry.coinPrices.count == 5)
        #expect(entry.currency == "USD")
        
        // Verify placeholder coins
        #expect(entry.coinPrices[0].symbol == "BTC")
        #expect(entry.coinPrices[1].symbol == "ETH")
        #expect(entry.coinPrices[2].symbol == "SOL")
        #expect(entry.coinPrices[3].symbol == "XRP")
        #expect(entry.coinPrices[4].symbol == "BNB")
    }
}

struct CoinPriceTests {
    
    @Test
    func initialization() {
        let assetId = AssetId(chain: .bitcoin, tokenId: nil)
        let coin = CoinPrice(
            assetId: assetId,
            name: "Bitcoin",
            symbol: "BTC",
            price: 50000,
            priceChangePercentage24h: 3.5,
            imageURL: URL(string: "https://example.com/btc.png")
        )
        
        #expect(coin.assetId == assetId)
        #expect(coin.name == "Bitcoin")
        #expect(coin.symbol == "BTC")
        #expect(coin.price == 50000)
        #expect(coin.priceChangePercentage24h == 3.5)
        #expect(coin.imageURL?.absoluteString == "https://example.com/btc.png")
    }
    
    @Test
    func placeholders() {
        let placeholders = CoinPrice.placeholders()
        
        #expect(placeholders.count == 5)
        
        // Verify all have image URLs from AssetImageFormatter
        for coin in placeholders {
            #expect(coin.imageURL != nil)
        }
    }
}