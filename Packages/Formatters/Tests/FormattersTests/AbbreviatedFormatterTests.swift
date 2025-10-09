// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Formatters

struct AbbreviatedFormatterTests {
    let formatter = AbbreviatedFormatter(locale: .US, threshold: 100_000)
    
    @Test
    func abbreviatedFormatter() {
        #expect(formatter.string(from: 99_999.0) == nil)
        #expect(formatter.string(from: 100_000.0) == "100K")
        #expect(formatter.string(from: 1_500_000.0) == "1.5M")
        #expect(formatter.string(from: 2_300_000_000.0) == "2.3B")
        #expect(formatter.string(from: 1_200_000_000_000.0) == "1.2T")
        #expect(formatter.string(from: 500_000.0, currency: "USD") == "$500K")
        #expect(formatter.string(from: 2_000_000.0, currency: "EUR") == "€2M")
        #expect(formatter.string(from: 2_500_000.0, currency: "USD") == "$2.5M")
    }
    
    @Test
    func customThreshold() {
        let formatter = AbbreviatedFormatter(locale: .US, threshold: 1_000)
        
        #expect(formatter.string(from: 1_500.0) == "1.5K")
        #expect(formatter.string(from: 500.0) == nil)
    }
}
