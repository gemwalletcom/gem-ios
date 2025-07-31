// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Perpetuals

struct PerpetualPriceFormatterTests {
    
    let formatter = PerpetualPriceFormatter()
    
    @Test
    func formatPrice() {
        // According to Hyperliquid docs:
        // For perpetuals: max decimal places = 6 - szDecimals
        // Prices have up to 5 significant figures
        
        // If szDecimals=0, max decimal places = 6
        // Small values should show with proper precision (NumberFormatter removes trailing zeros)
        #expect(formatter.formatPrice(0.002877, decimals: 0) == "0.002877")
        #expect(formatter.formatPrice(0.002840, decimals: 0) == "0.00284")  // Trailing zero removed
        #expect(formatter.formatPrice(0.003003, decimals: 0) == "0.003003")
        #expect(formatter.formatPrice(12345.678, decimals: 0) == "12346") // 5 sig figs
        #expect(formatter.formatPrice(1234.5, decimals: 0) == "1234.5")
        #expect(formatter.formatPrice(123.45, decimals: 0) == "123.45")
        
        // If szDecimals=1, max decimal places = 5
        #expect(formatter.formatPrice(1234.567, decimals: 1) == "1234.6") // 5 sig figs
        #expect(formatter.formatPrice(123.456, decimals: 1) == "123.46")
        #expect(formatter.formatPrice(0.0012345, decimals: 1) == "0.00123") // 5 sig figs
        
        // If szDecimals=2, max decimal places = 4
        #expect(formatter.formatPrice(123.456, decimals: 2) == "123.46")
        #expect(formatter.formatPrice(12.3456, decimals: 2) == "12.346")
        #expect(formatter.formatPrice(1.23456, decimals: 2) == "1.2346")
        
        // If szDecimals=3, max decimal places = 3
        #expect(formatter.formatPrice(12.3456, decimals: 3) == "12.346")
        #expect(formatter.formatPrice(1.2345, decimals: 3) == "1.234") // Rounded to 3 decimals
        
        // If szDecimals=4, max decimal places = 2
        #expect(formatter.formatPrice(1.2345, decimals: 4) == "1.23")
        #expect(formatter.formatPrice(0.12345, decimals: 4) == "0.12")
    }
    
    @Test
    func formatSize() {
        #expect(formatter.formatSize(123.456789) == "123.456789")
        #expect(formatter.formatSize(0.123456) == "0.123456")
        #expect(formatter.formatSize(1000) == "1000")
        #expect(formatter.formatSize(0.000000000000001) == "0.000000000000001")
    }
}
