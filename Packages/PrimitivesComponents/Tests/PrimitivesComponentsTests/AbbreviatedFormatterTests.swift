// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import PrimitivesComponents

struct AbbreviatedFormatterTests {
    
    @Test func abbreviatedString() {
        let formatter = AbbreviatedFormatter(
            locale: .US,
            currencyFormatter: CurrencyFormatter(type: .currencyShort, currencyCode: "USD")
        )
        
        #expect(formatter.string(0) == "$0")
        #expect(formatter.string(12) == "$12")
        #expect(formatter.string(1_234) == "$1,234")
        #expect(formatter.string(12_234) == "$12,234")
        #expect(formatter.string(100_000) == "$100K")
        #expect(formatter.string(123_456) == "$123.46K")
        #expect(formatter.string(5_000_000) == "$5M")
        #expect(formatter.string(7_890_000_000) == "$7.89B")
        #expect(formatter.string(1_200_000_000_000) == "$1.2T")

        #expect(formatter.string(-1234) == "-$1,234")
        #expect(formatter.string(-5_600_000) == "-$5.6M")
        #expect(formatter.string(-9_999_999_999) == "-$10B")
    }
    
    @Test func abbreviatedStringSymbol() {
        let formatter = AbbreviatedFormatter(locale: .US, currencyFormatter: CurrencyFormatter(type: .currencyShort, currencyCode: "USD"))
        
        #expect(formatter.string(0, symbol: "BTC") == "0 BTC")
        #expect(formatter.string(12, symbol: "BTC") == "12 BTC")
        #expect(formatter.string(1_234, symbol: "BTC") == "1,234 BTC")
        #expect(formatter.string(5_000_000, symbol: "BTC") == "5M BTC")
        #expect(formatter.string(7_890_000_000, symbol: "BTC") == "7.89B BTC")
    }
    
    @Test func abbreviatedStringItLocale() {
        let formatter = AbbreviatedFormatter(locale: .IT, currencyFormatter: CurrencyFormatter(type: .currencyShort, currencyCode: "EUR"))
        
        #expect(formatter.string(0) == "€0")
        #expect(formatter.string(12) == "€12")
        #expect(formatter.string(1_234) == "€1,234")
        #expect(formatter.string(5_000_000) == "5 Mln €")
        #expect(formatter.string(7_890_000_000) == "7,89 Mld €")
        #expect(formatter.string(1_200_000_000_000) == "1,2 Bln €")
    }
}
