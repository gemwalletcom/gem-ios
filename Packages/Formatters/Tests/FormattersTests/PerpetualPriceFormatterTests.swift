// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Formatters
import Primitives

struct PerpetualPriceFormatterTests {
    
    let formatter = PerpetualPriceFormatter()
    let provider = PerpetualProvider.hypercore
    
    @Test
    func formatPrice() {
        // According to Hyperliquid docs:
        // For perpetuals: max decimal places = 6 - szDecimals
        // Prices have up to 5 significant figures
        
        // If szDecimals=0, max decimal places = 6
        // Small values should show with proper precision (NumberFormatter removes trailing zeros)
        #expect(formatter.formatPrice(provider: provider, 0.002877, decimals: 0) == "0.002877")
        #expect(formatter.formatPrice(provider: provider, 0.002840, decimals: 0) == "0.00284")  // Trailing zero removed
        #expect(formatter.formatPrice(provider: provider, 0.003003, decimals: 0) == "0.003003")
        #expect(formatter.formatPrice(provider: provider, 12345.678, decimals: 0) == "12346") // 5 sig figs
        #expect(formatter.formatPrice(provider: provider, 1234.5, decimals: 0) == "1234.5")
        #expect(formatter.formatPrice(provider: provider, 123.45, decimals: 0) == "123.45")
        
        // If szDecimals=1, max decimal places = 5
        #expect(formatter.formatPrice(provider: provider, 1234.567, decimals: 1) == "1234.6") // 5 sig figs
        #expect(formatter.formatPrice(provider: provider, 123.456, decimals: 1) == "123.46")
        #expect(formatter.formatPrice(provider: provider, 0.0012345, decimals: 1) == "0.00123") // 5 sig figs
        
        // If szDecimals=2, max decimal places = 4
        #expect(formatter.formatPrice(provider: provider, 123.456, decimals: 2) == "123.46")
        #expect(formatter.formatPrice(provider: provider, 12.3456, decimals: 2) == "12.346")
        #expect(formatter.formatPrice(provider: provider, 1.23456, decimals: 2) == "1.2346")
        
        // If szDecimals=3, max decimal places = 3
        #expect(formatter.formatPrice(provider: provider, 12.3456, decimals: 3) == "12.346")
        #expect(formatter.formatPrice(provider: provider, 1.2345, decimals: 3) == "1.234") // Rounded to 3 decimals
        
        // If szDecimals=4, max decimal places = 2
        #expect(formatter.formatPrice(provider: provider, 1.2345, decimals: 4) == "1.23")
        #expect(formatter.formatPrice(provider: provider, 0.12345, decimals: 4) == "0.12")
    }
    
    @Test
    func formatSize() {
        // Sizes are rounded to the szDecimals of that asset
        
        // If szDecimals=0, no decimal places allowed
        #expect(formatter.formatSize(provider: provider, 123.456789, decimals: 0) == "123")
        #expect(formatter.formatSize(provider: provider, 0.123456, decimals: 0) == "0")
        #expect(formatter.formatSize(provider: provider, 1000.5, decimals: 0) == "1001")
        
        // If szDecimals=1, 1 decimal place allowed
        #expect(formatter.formatSize(provider: provider, 123.456, decimals: 1) == "123.5")
        #expect(formatter.formatSize(provider: provider, 0.123456, decimals: 1) == "0.1")
        #expect(formatter.formatSize(provider: provider, 1.05, decimals: 1) == "1.1")
        
        // If szDecimals=3, 3 decimal places allowed
        #expect(formatter.formatSize(provider: provider, 0.123456, decimals: 3) == "0.123")
        #expect(formatter.formatSize(provider: provider, 1.234567, decimals: 3) == "1.235")
        
        // If szDecimals=6, 6 decimal places allowed
        #expect(formatter.formatSize(provider: provider, 0.123456789, decimals: 6) == "0.123457")
    }
}