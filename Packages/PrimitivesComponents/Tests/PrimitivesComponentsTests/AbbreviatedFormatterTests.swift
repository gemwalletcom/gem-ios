// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import PrimitivesComponents

struct AbbreviatedFormatterTests {
    
    @Test func abbreviatedString() {
        let abbreviatedFormatter = AbbreviatedFormatter(locale: .US, currencyCode: "USD")
        
        #expect(abbreviatedFormatter.string(0) == "$0")
        #expect(abbreviatedFormatter.string(12) == "$12")
        #expect(abbreviatedFormatter.string(1_234) == "$1,234")
        #expect(abbreviatedFormatter.string(5_000_000) == "$5M")
        #expect(abbreviatedFormatter.string(7_890_000_000) == "$7.89B")
        #expect(abbreviatedFormatter.string(1_200_000_000_000) == "$1.2T")

        #expect(abbreviatedFormatter.string(-1234) == "-$1,234")
        #expect(abbreviatedFormatter.string(-5_600_000) == "-$5.6M")
        #expect(abbreviatedFormatter.string(-9_999_999_999) == "-$10B")
    }
    
    @Test func abbreviatedStringSymbol() {
        let abbreviatedFormatter = AbbreviatedFormatter(locale: .US, currencyCode: "USD")
        
        #expect(abbreviatedFormatter.string(0, symbol: "BTC") == "0 BTC")
        #expect(abbreviatedFormatter.string(12, symbol: "BTC") == "12 BTC")
        #expect(abbreviatedFormatter.string(1_234, symbol: "BTC") == "1,234 BTC")
        #expect(abbreviatedFormatter.string(5_000_000, symbol: "BTC") == "5M BTC")
        #expect(abbreviatedFormatter.string(7_890_000_000, symbol: "BTC") == "7.89B BTC")
    }
    
    @Test func abbreviatedStringItLocale() {
        let abbreviatedFormatter = AbbreviatedFormatter(locale: .IT, currencyCode: "EUR")
        
        #expect(abbreviatedFormatter.string(0) == "0 €")
        #expect(abbreviatedFormatter.string(12) == "12 €")
        #expect(abbreviatedFormatter.string(1_234) == "1.234 €")
        #expect(abbreviatedFormatter.string(5_000_000) == "5 Mio €")
        #expect(abbreviatedFormatter.string(7_890_000_000) == "7,89 Mrd €")
        #expect(abbreviatedFormatter.string(1_200_000_000_000) == "1,2 Bln €")
    }
}
