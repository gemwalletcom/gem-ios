// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import PrimitivesComponents

struct AbbreviatedFormatterTests {
    let abbreviatedFormatter = AbbreviatedFormatter(locale: .US, currencyCode: "USD")
    
    @Test
    func abbreviatedTest() {
        
        #expect(abbreviatedFormatter.string(0) == "$0")
        #expect(abbreviatedFormatter.string(12) == "$12")
        #expect(abbreviatedFormatter.string(1_234) == "$1.23K")
        #expect(abbreviatedFormatter.string(5_000_000) == "$5M")
        #expect(abbreviatedFormatter.string(7_890_000_000) == "$7.89B")
        #expect(abbreviatedFormatter.string(1_200_000_000_000) == "$1.2T")

        #expect(abbreviatedFormatter.string(-1234) == "-$1.23K")
        #expect(abbreviatedFormatter.string(-5_600_000) == "-$5.6M")
        #expect(abbreviatedFormatter.string(-9_999_999_999) == "-$10B")
    }
    
    @Test
    func simbolTest() {
        #expect(abbreviatedFormatter.stringSymbol(12, symbol: "BTC") == "12 BTC")
        #expect(abbreviatedFormatter.stringSymbol(0, symbol: "BTC") == "0 BTC")
        #expect(abbreviatedFormatter.stringSymbol(1_234, symbol: "BTC") == "1.23K BTC")
        #expect(abbreviatedFormatter.stringSymbol(5_000_000, symbol: "BTC") == "5M BTC")
        #expect(abbreviatedFormatter.stringSymbol(7_890_000_000, symbol: "BTC") == "7.89B BTC")
        #expect(abbreviatedFormatter.stringSymbol(1_200_000_000_000, symbol: "BTC") == "1.2T BTC")

        #expect(abbreviatedFormatter.stringSymbol(-1234, symbol: "BTC") == "-1.23K BTC")
        #expect(abbreviatedFormatter.stringSymbol(-5_600_000, symbol: "BTC") == "-5.6M BTC")
        #expect(abbreviatedFormatter.stringSymbol(-9_999_999_999, symbol: "BTC") == "-10B BTC")
    }
    
    @Test
    func withoutSymbolTest() {
        #expect(abbreviatedFormatter.stringSymbol(12) == "12")
        #expect(abbreviatedFormatter.stringSymbol(0) == "0")
        #expect(abbreviatedFormatter.stringSymbol(1_234) == "1.23K")

        #expect(abbreviatedFormatter.stringSymbol(-1234) == "-1.23K")
        #expect(abbreviatedFormatter.stringSymbol(-5_600_000) == "-5.6M")
        #expect(abbreviatedFormatter.stringSymbol(-9_999_999_999) == "-10B")
    }
}
