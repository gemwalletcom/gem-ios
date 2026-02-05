// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Formatters

struct RoundingFormatterTests {

    let formatter = RoundingFormatter()

    @Test
    func roundedValues() {
        #expect(formatter.roundedValues(for: 0.0, byPercent: 5) == [])
        #expect(formatter.roundedValues(for: 0.009, byPercent: 5) == [])
        #expect(formatter.roundedValues(for: 0.2829, byPercent: 5) == [0.26, 0.3])
        #expect(formatter.roundedValues(for: 3.90, byPercent: 5) == [3, 5])
        #expect(formatter.roundedValues(for: 10.05, byPercent: 5) == [9, 11])
        #expect(formatter.roundedValues(for: 103.0, byPercent: 5) == [97, 109])
        #expect(formatter.roundedValues(for: 767.55, byPercent: 5) == [700, 800])
        #expect(formatter.roundedValues(for: 2283.0, byPercent: 5) == [2150, 2400])
        #expect(formatter.roundedValues(for: 95432.0, byPercent: 5) == [90000, 100000])
        #expect(formatter.roundedValues(for: 110000.0, byPercent: 5) == [104000, 116000])
        #expect(formatter.roundedValues(for: 149000.0, byPercent: 5) == [141000, 156000])
    }
}
