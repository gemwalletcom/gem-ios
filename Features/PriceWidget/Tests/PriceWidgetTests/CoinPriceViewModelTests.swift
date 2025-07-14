// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
@testable import PriceWidget
import Primitives

struct CoinPriceViewModelTests {
    
    @Test
    func priceFormatting() {
        let coin = CoinPrice(
            assetId: AssetId(chain: .bitcoin, tokenId: nil),
            name: "Bitcoin",
            symbol: "BTC",
            price: 45000,
            priceChangePercentage24h: 2.5,
            imageURL: nil
        )
        
        let viewModel = CoinPriceViewModel(coin: coin, currency: "USD")
        
        #expect(viewModel.name == "Bitcoin")
        #expect(viewModel.symbol == "BTC")
        #expect(viewModel.priceText.contains("45"))
        #expect(viewModel.priceText.contains("000"))
        #expect(viewModel.percentageText == "+2.50%")
    }
}
