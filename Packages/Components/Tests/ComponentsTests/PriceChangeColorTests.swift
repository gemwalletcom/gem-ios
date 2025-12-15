// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import SwiftUI
import Style
@testable import Components

struct PriceChangeColorTests {
    
    @Test
    func positiveValue() {
        #expect(PriceChangeColor.color(for: 1.0) == Colors.green)
        #expect(PriceChangeColor.color(for: 0.01) == Colors.green)
        #expect(PriceChangeColor.color(for: 100.0) == Colors.green)
    }
    
    @Test
    func negativeValue() {
        #expect(PriceChangeColor.color(for: -1.0) == Colors.red)
        #expect(PriceChangeColor.color(for: -0.01) == Colors.red)
        #expect(PriceChangeColor.color(for: -100.0) == Colors.red)
    }
    
    @Test
    func zeroValue() {
        #expect(PriceChangeColor.color(for: 0.0) == Colors.gray)
        #expect(PriceChangeColor.color(for: -0.0) == Colors.gray)
    }
}