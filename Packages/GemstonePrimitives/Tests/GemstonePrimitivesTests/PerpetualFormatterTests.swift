// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import GemstonePrimitives
import Primitives
import Foundation

struct PerpetualPriceFormatterTests {

    let formatter = PerpetualFormatter(provider: PerpetualProvider.hypercore)
    
    @Test
    func formatInputPrice() {
        let usLocale = Locale(identifier: "en_US")

        #expect(formatter.formatInputPrice(3397.10, decimals: 0, locale: usLocale) == "3397.1")
        #expect(formatter.formatInputPrice(3532.984, decimals: 0, locale: usLocale) == "3533")
        #expect(formatter.formatInputPrice(3261.216, decimals: 0, locale: usLocale) == "3261.2")

        #expect(formatter.formatInputPrice(123.456, decimals: 0, locale: usLocale) == "123.46")
        #expect(formatter.formatInputPrice(99.999, decimals: 0, locale: usLocale) == "99.999")

        #expect(formatter.formatInputPrice(0.005849, decimals: 0, locale: usLocale) == "0.005849")
        #expect(formatter.formatInputPrice(0.0061415, decimals: 0, locale: usLocale) == "0.006142")
        #expect(formatter.formatInputPrice(0.0052641, decimals: 0, locale: usLocale) == "0.005264")

        #expect(formatter.formatInputPrice(3397.10, decimals: 4, locale: usLocale) == "3397.1")
        #expect(formatter.formatInputPrice(3532.984, decimals: 4, locale: usLocale) == "3533")
        #expect(formatter.formatInputPrice(0.005849, decimals: 4, locale: usLocale) == "0.01")

        #expect(formatter.formatInputPrice(0.0, decimals: 6, locale: usLocale) == "0")
        #expect(formatter.formatInputPrice(1.0, decimals: 6, locale: usLocale) == "1")
        #expect(formatter.formatInputPrice(0.000001, decimals: 6, locale: usLocale) == "0")
        #expect(formatter.formatInputPrice(123.456, decimals: 6, locale: usLocale) == "123")

        let euLocale = Locale(identifier: "de_DE")
        #expect(formatter.formatInputPrice(3397.10, decimals: 0, locale: euLocale) == "3397,1")
        #expect(formatter.formatInputPrice(0.005849, decimals: 0, locale: euLocale) == "0,005849")
        #expect(formatter.formatInputPrice(3532.984, decimals: 4, locale: euLocale) == "3533")

        let frLocale = Locale(identifier: "fr_FR")
        #expect(formatter.formatInputPrice(1234.56, decimals: 0, locale: frLocale) == "1234,6")
        #expect(formatter.formatInputPrice(0.123456, decimals: 0, locale: frLocale) == "0,12346")

        let esLocale = Locale(identifier: "es_ES")
        #expect(formatter.formatInputPrice(999.99, decimals: 0, locale: esLocale) == "999,99")

        let ukLocale = Locale(identifier: "en_GB")
        #expect(formatter.formatInputPrice(100.1, decimals: 0, locale: ukLocale) == "100.1")
    }
}
